@isTest
private class TripAutoCancelBatchTest {
    @TestSetup
    static void setup() {
        insert new Account(Name = 'Compte GGT04');
    }

    private static Trip_Settings__mdt getSettings() {
        return [SELECT Min_Participants__c, Days_Before_Departure__c FROM Trip_Settings__mdt WHERE DeveloperName = 'Default' LIMIT 1];
    }

    @isTest
    static void tripWithFewParticipantsAtTargetDate_isCancelled() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip_Settings__mdt settings = getSettings();
        Date targetDate = Date.today().addDays(Integer.valueOf(settings.Days_Before_Departure__c));

        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Nice',
            Start_Date__c = targetDate,
            End_Date__c = targetDate.addDays(3),
            Number_of_Participants__c = settings.Min_Participants__c - 1
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripAutoCancelBatch(), 200);
        Test.stopTest();

        System.assertEquals('Annulé', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }

    @isTest
    static void tripWithEnoughParticipantsAtTargetDate_isNotCancelled() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip_Settings__mdt settings = getSettings();
        Date targetDate = Date.today().addDays(Integer.valueOf(settings.Days_Before_Departure__c));

        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Cannes',
            Start_Date__c = targetDate,
            End_Date__c = targetDate.addDays(3),
            Number_of_Participants__c = settings.Min_Participants__c + 5
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripAutoCancelBatch(), 200);
        Test.stopTest();

        System.assertEquals('À venir', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }

    @isTest
    static void tripWithNullParticipantsAtTargetDate_isNotCancelled() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip_Settings__mdt settings = getSettings();
        Date targetDate = Date.today().addDays(Integer.valueOf(settings.Days_Before_Departure__c));

        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Monaco',
            Start_Date__c = targetDate,
            End_Date__c = targetDate.addDays(3)
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripAutoCancelBatch(), 200);
        Test.stopTest();

        System.assertEquals('À venir', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }

    @isTest
    static void alreadyCancelledTrip_isNotReprocessed() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip_Settings__mdt settings = getSettings();
        Date targetDate = Date.today().addDays(Integer.valueOf(settings.Days_Before_Departure__c));

        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Déjà Annulé',
            Start_Date__c = targetDate,
            End_Date__c = targetDate.addDays(3),
            Number_of_Participants__c = settings.Min_Participants__c - 1,
            Status__c = 'Annulé'
        );
        insert trip;

        Test.startTest();
        Database.executeBatch(new TripAutoCancelBatch(), 200);
        Test.stopTest();

        System.assertEquals('Annulé', [SELECT Status__c FROM Trip__c WHERE Id = :trip.Id].Status__c);
    }
}
