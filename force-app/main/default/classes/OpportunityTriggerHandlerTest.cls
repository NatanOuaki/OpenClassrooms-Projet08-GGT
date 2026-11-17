@isTest
private class OpportunityTriggerHandlerTest {
    @TestSetup
    static void setup() {
        insert new Account(Name = 'Association Sportive Test');
    }

    @isTest
    static void closedWonTransition_createsTripWithExpectedMapping() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestDataFactory.createTripOpportunity(
            acc.Id,
            'Séjour Ski',
            'Prospecting',
            12000,
            'Chamonix',
            Date.today().addDays(60),
            Date.today().addDays(67),
            25
        );

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
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, 'Séjour Annulé Avant Signature', 'Prospecting', 3000);

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
            opportunities.add(TestDataFactory.buildTripOpportunity(
                acc.Id,
                'Voyage Bulk ' + i,
                'Prospecting',
                1000,
                'Destination ' + i,
                Date.today().addDays(40),
                Date.today().addDays(45),
                15
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
    static void deleteAndUndeleteOpportunity_isDispatchedWithoutCreatingTrip() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, 'Voyage Supprimé Puis Restauré', 'Prospecting', null);

        Test.startTest();
        delete opp;
        undelete opp;
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE Id = :opp.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Trip__c]);
    }

    @isTest
    static void alreadyClosedWonOpportunity_updatedAgain_doesNotCreateDuplicateTrip() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = TestDataFactory.createTripOpportunity(
            acc.Id,
            'Voyage Déjà Signé',
            'Closed Won',
            2000,
            'Barcelone',
            Date.today().addDays(20),
            Date.today().addDays(25),
            10
        ); // insert ne déclenche pas notre trigger after update : aucun Trip__c créé ici.

        opp.Amount = 2500; // reste Closed Won -> Closed Won : ce n'est pas une transition "vient de passer à Closed Won".
        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Trip__c WHERE Opportunity__c = :opp.Id]);
    }
}
