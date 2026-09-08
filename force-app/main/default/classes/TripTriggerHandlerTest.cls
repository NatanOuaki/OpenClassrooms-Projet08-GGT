@isTest
private class TripTriggerHandlerTest {
    @TestSetup
    static void setup() {
        insert new Account(Name = 'Compte Test GGT03');
    }

    @isTest
    static void insert_withEndDateBeforeStartDate_isRejected() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Lisbonne',
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(5)
        );

        Database.SaveResult result = Database.insert(trip, false);

        System.assertEquals(false, result.isSuccess());
        System.assertEquals(
            'La date de fin doit être postérieure à la date de début.',
            result.getErrors()[0].getMessage()
        );
    }

    @isTest
    static void insert_withConsistentDates_isAccepted() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Lisbonne',
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10)
        );

        insert trip;

        System.assertNotEquals(null, [SELECT Id FROM Trip__c WHERE Id = :trip.Id].Id);
    }

    @isTest
    static void insert_withOneDateBlank_doesNotThrowAndFailsOnRequiredFieldInstead() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Lisbonne',
            Start_Date__c = Date.today()
            // End_Date__c volontairement absent : vérifie que la validation GGT-03 ne lève pas
            // d'exception (NullPointerException) quand une des deux dates est vide.
        );

        Database.SaveResult result = Database.insert(trip, false);

        System.assertEquals(false, result.isSuccess());
        System.assert(
            !result.getErrors()[0].getMessage().contains('La date de fin doit être postérieure'),
            'L\'échec attendu ici est le champ requis manquant, pas la règle de cohérence des dates.'
        );
    }

    @isTest
    static void update_withEndDateMovedBeforeStartDate_isRejected() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Athènes',
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10)
        );
        insert trip;

        trip.End_Date__c = Date.today().addDays(1);

        Database.SaveResult result = Database.update(trip, false);

        System.assertEquals(false, result.isSuccess());
        System.assertEquals(
            'La date de fin doit être postérieure à la date de début.',
            result.getErrors()[0].getMessage()
        );
    }
}
