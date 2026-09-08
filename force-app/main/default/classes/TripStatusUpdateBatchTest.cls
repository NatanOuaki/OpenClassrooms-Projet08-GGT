@isTest
private class TripStatusUpdateBatchTest {
    @TestSetup
    static void setup() {
        insert new Account(Name = 'Compte GGT05');
    }

    @isTest
    static void futureTrip_isSetToAVenir() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Tokyo',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(20),
            Status__c = 'Terminé' // valeur volontairement incohérente pour vérifier le recalcul
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripStatusUpdateBatch(), 200);
        Test.stopTest();

        System.assertEquals('À venir', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }

    @isTest
    static void ongoingTrip_isSetToEnCours() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Marrakech',
            Start_Date__c = Date.today().addDays(-2),
            End_Date__c = Date.today().addDays(2)
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripStatusUpdateBatch(), 200);
        Test.stopTest();

        System.assertEquals('En cours', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }

    @isTest
    static void pastTrip_isSetToTermine() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Berlin',
            Start_Date__c = Date.today().addDays(-20),
            End_Date__c = Date.today().addDays(-10)
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripStatusUpdateBatch(), 200);
        Test.stopTest();

        System.assertEquals('Terminé', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }

    @isTest
    static void cancelledTrip_isNeverModifiedEvenIfDatesWouldMeanTermine() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Le Caire',
            Start_Date__c = Date.today().addDays(-20),
            End_Date__c = Date.today().addDays(-10),
            Status__c = 'Annulé'
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripStatusUpdateBatch(), 200);
        Test.stopTest();

        System.assertEquals('Annulé', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }
}
