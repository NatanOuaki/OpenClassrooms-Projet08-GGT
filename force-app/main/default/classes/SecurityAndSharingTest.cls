/**
 * Tests de sécurité exécutés avec System.runAs() sous un user n'ayant que le
 * Permission Set Commercial_GlobalGroupTravel : vérifie la FLS (Total_Cost__c en
 * lecture seule) et la Sharing Rule (visibilité des Trip__c "Annulé").
 */
@isTest
private class SecurityAndSharingTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Compte Securite');
        insert acc;

        insert new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Dubai',
            Start_Date__c = Date.today().addDays(-30),
            End_Date__c = Date.today().addDays(-20),
            Status__c = 'Annulé'
        );
    }

    private static User createRestrictedUser() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Utilisateur standard' LIMIT 1];
        String uniqueSuffix = String.valueOf(DateTime.now().getTime());
        User restrictedUser = new User(
            FirstName = 'Commercial',
            LastName = 'GGT Test',
            Alias = 'ggtres',
            Email = 'ggt.restricted' + uniqueSuffix + '@globalgrouptravel.test',
            Username = 'ggt.restricted' + uniqueSuffix + '@globalgrouptravel.test',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'fr_FR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'fr',
            ProfileId = standardProfile.Id
        );
        insert restrictedUser;

        PermissionSet commercialPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Commercial_GlobalGroupTravel' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = restrictedUser.Id, PermissionSetId = commercialPermissionSet.Id);

        return restrictedUser;
    }

    @isTest
    static void restrictedUser_cannotEditTotalCostEvenThroughTripService() {
        User restrictedUser = createRestrictedUser();

        System.runAs(restrictedUser) {
            Account ownAccount = new Account(Name = 'Compte Restricted User');
            insert ownAccount;

            Trip__c ownTrip = new Trip__c(
                Account__c = ownAccount.Id,
                Destination__c = 'Malte',
                Start_Date__c = Date.today().addDays(5),
                End_Date__c = Date.today().addDays(10),
                Total_Cost__c = 100
            );
            insert ownTrip;

            ownTrip.Total_Cost__c = 5000;
            new TripService().updateTrips(new List<Trip__c>{ ownTrip });

            Trip__c reloaded = [SELECT Total_Cost__c FROM Trip__c WHERE Id = :ownTrip.Id];
            System.assertEquals(
                100,
                reloaded.Total_Cost__c,
                'Total_Cost__c doit rester inchangé : FLS en lecture seule pour ce Permission Set.'
            );
        }
    }

    /**
     * Vérifie que, sans appartenance au groupe partagé Managers_GlobalGroupTravel,
     * un user n'ayant que le Permission Set Commercial_GlobalGroupTravel ne voit pas
     * les Trip__c "Annulé" appartenant à un autre user (OWD Private sur Trip__c).
     *
     * Note : le pendant "devient visible après ajout au groupe" n'est volontairement pas
     * testé ici. Le recalcul de partage déclenché par une Sharing Rule (contrairement à un
     * partage manuel Apex ou à la hiérarchie de rôles) est un traitement asynchrone géré par
     * la plateforme Salesforce, qui ne s'exécute jamais de façon synchrone dans un test Apex,
     * même entre Test.startTest()/stopTest(). Écrire une assertion sur ce recalcul produirait
     * un test non déterministe qui ne vérifie rien de fiable ; ce comportement est à valider
     * manuellement dans l'org (voir docs/DOCUMENTATION.md, section Limites connues).
     */
    @isTest
    static void cancelledTrip_isNotVisibleWithoutManagersGroupMembership() {
        User restrictedUser = createRestrictedUser();

        System.runAs(restrictedUser) {
            System.assertEquals(
                0,
                [SELECT COUNT() FROM Trip__c WHERE Status__c = 'Annulé'],
                'Sans appartenance au groupe partagé, le Trip__c Annulé du TestSetup ne doit pas être visible.'
            );
        }
    }
}
