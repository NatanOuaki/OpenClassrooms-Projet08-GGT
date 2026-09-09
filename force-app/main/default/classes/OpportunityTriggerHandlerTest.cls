@isTest
private class OpportunityTriggerHandlerTest {
    @TestSetup
    static void setup() {
        insert new Account(Name = 'Association Sportive Test');
    }

    @isTest
    static void closedWonTransition_createsTripWithExpectedMapping() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Séjour Ski',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 12000,
            Destination__c = 'Chamonix',
            Start_Date__c = Date.today().addDays(60),
            End_Date__c = Date.today().addDays(67),
            Number_of_Participants__c = 25
        );
        insert opp;

        opp.StageName = 'Closed Won';
        Test.startTest();
        update opp;
        Test.stopTest();

        List<Trip__c> trips = [
            SELECT Status__c, Destination__c, Total_Cost__c, Account__c, Opportunity__c
            FROM Trip__c
            WHERE Opportunity__c = :opp.Id
        ];
        System.assertEquals(1, trips.size());
        System.assertEquals('À venir', trips[0].Status__c);
        System.assertEquals('Chamonix', trips[0].Destination__c);
        System.assertEquals(12000, trips[0].Total_Cost__c);
        System.assertEquals(acc.Id, trips[0].Account__c);
    }

    @isTest
    static void transitionToOtherStage_doesNotCreateTrip() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Séjour Annulé Avant Signature',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 3000
        );
        insert opp;

        opp.StageName = 'Closed Lost';
        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Trip__c WHERE Opportunity__c = :opp.Id]);
    }

    @isTest
    static void bulkClosedWonTransition_createsOneTripPerOpportunity() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) {
            opportunities.add(new Opportunity(
                Name = 'Voyage Bulk ' + i,
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Amount = 1000,
                Destination__c = 'Destination ' + i,
                Start_Date__c = Date.today().addDays(40),
                End_Date__c = Date.today().addDays(45),
                Number_of_Participants__c = 15
            ));
        }
        insert opportunities;

        for (Opportunity opp : opportunities) {
            opp.StageName = 'Closed Won';
        }

        Test.startTest();
        update opportunities;
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Trip__c]);
    }

    @isTest
    static void alreadyClosedWonOpportunity_updatedAgain_doesNotCreateDuplicateTrip() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Voyage Déjà Signé',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 2000,
            Destination__c = 'Barcelone',
            Start_Date__c = Date.today().addDays(20),
            End_Date__c = Date.today().addDays(25),
            Number_of_Participants__c = 10
        );
        insert opp; // insert ne déclenche pas notre trigger after update : aucun Trip__c créé ici.

        opp.Amount = 2500; // reste Closed Won -> Closed Won : ce n'est pas une transition "vient de passer à Closed Won".
        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Trip__c WHERE Opportunity__c = :opp.Id]);
    }
}
