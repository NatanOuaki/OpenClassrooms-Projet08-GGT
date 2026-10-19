@isTest
private class TripServiceTest {
    @TestSetup
    static void setup() {
        insert new Account(Name = 'Ecole Test TripService');
    }

    @isTest
    static void createTripsFromOpportunities_mapsAllFieldsFromClosedWonOpportunity() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Voyage Test',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 5000,
            Destination__c = 'Rome',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(35),
            Number_of_Participants__c = 20
        );
        insert opp;

        Test.startTest();
        new TripService().createTripsFromOpportunities(new List<Opportunity>{ opp });
        Test.stopTest();

        List<Trip__c> trips = [
            SELECT Status__c, Destination__c, Start_Date__c, End_Date__c, Number_of_Participants__c, Total_Cost__c, Account__c, Opportunity__c
            FROM Trip__c
            WHERE Opportunity__c = :opp.Id
        ];
        System.assertEquals(1, trips.size());
        Trip__c trip = trips[0];
        System.assertEquals('À venir', trip.Status__c);
        System.assertEquals('Rome', trip.Destination__c);
        System.assertEquals(opp.Start_Date__c, trip.Start_Date__c);
        System.assertEquals(opp.End_Date__c, trip.End_Date__c);
        System.assertEquals(20, trip.Number_of_Participants__c);
        System.assertEquals(5000, trip.Total_Cost__c);
        System.assertEquals(acc.Id, trip.Account__c);
        System.assertEquals(opp.Id, trip.Opportunity__c);
    }

    @isTest
    static void createTripsFromOpportunities_skipsOpportunityMissingRequiredTripFieldsWithoutError() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Voyage Incomplet',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 1000
            // Destination__c / Start_Date__c / End_Date__c volontairement absents.
        );
        insert opp;

        new TripService().createTripsFromOpportunities(new List<Opportunity>{ opp });

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Trip__c WHERE Opportunity__c = :opp.Id],
            'Destination__c/Start_Date__c/End_Date__c étant obligatoires sur Trip__c, aucun Trip__c ne doit être créé, mais sans lever d\'exception.'
        );
    }

    @isTest
    static void createTripsForNewlyClosedWonOpportunities_createsTripOnlyForTransitionToClosedWon() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity prospectingOppty = new Opportunity(
            Name = 'Voyage Qui Vient De Signer',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Amount = 4000,
            Destination__c = 'Porto',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(34),
            Number_of_Participants__c = 12
        );
        Opportunity alreadyWonOppty = new Opportunity(
            Name = 'Voyage Déjà Signé',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 2000,
            Destination__c = 'Séville',
            Start_Date__c = Date.today().addDays(40),
            End_Date__c = Date.today().addDays(44),
            Number_of_Participants__c = 15
        );
        insert new List<Opportunity>{ prospectingOppty, alreadyWonOppty };

        Opportunity newlyWonOppty = prospectingOppty.clone(true);
        newlyWonOppty.StageName = 'Closed Won';
        Opportunity stillWonOppty = alreadyWonOppty.clone(true);
        stillWonOppty.Amount = 2500;

        Test.startTest();
        new TripService().createTripsForNewlyClosedWonOpportunities(
            new List<Opportunity>{ newlyWonOppty, stillWonOppty },
            new Map<Id, Opportunity>{ prospectingOppty.Id => prospectingOppty, alreadyWonOppty.Id => alreadyWonOppty }
        );
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Trip__c WHERE Opportunity__c = :prospectingOppty.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Trip__c WHERE Opportunity__c = :alreadyWonOppty.Id]);
    }

    @isTest
    static void createTripsForNewlyClosedWonOpportunities_doesNothingWhenNoOpportunityIsNewlyClosedWon() {
        Test.startTest();
        new TripService().createTripsForNewlyClosedWonOpportunities(new List<Opportunity>(), new Map<Id, Opportunity>());
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Trip__c]);
    }

    @isTest
    static void insertTrips_doesNothingWhenListEmpty() {
        new TripService().insertTrips(new List<Trip__c>());
        System.assertEquals(0, [SELECT COUNT() FROM Trip__c]);
    }

    @isTest
    static void cancelTrips_setsStatusToAnnule() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Madrid',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Number_of_Participants__c = 3
        );
        insert trip;

        new TripService().cancelTrips(new List<Trip__c>{ trip });

        System.assertEquals('Annulé', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }

    @isTest
    static void computeStatusForDates_returnsExpectedStatusForEachPeriod() {
        TripService service = new TripService();
        System.assertEquals('À venir', service.computeStatusForDates(Date.today().addDays(1), Date.today().addDays(5)));
        System.assertEquals('En cours', service.computeStatusForDates(Date.today().addDays(-1), Date.today().addDays(1)));
        System.assertEquals('Terminé', service.computeStatusForDates(Date.today().addDays(-10), Date.today().addDays(-1)));
    }
}
