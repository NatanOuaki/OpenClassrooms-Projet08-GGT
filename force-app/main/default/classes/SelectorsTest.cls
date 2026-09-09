@isTest
private class SelectorsTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Compte Selectors');
        insert acc;

        Contract contract = new Contract(AccountId = acc.Id, StartDate = Date.today(), ContractTerm = 12);
        insert contract;

        Opportunity opp = new Opportunity(
            Name = 'Opp Selectors',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;

        Trip__c trip = new Trip__c(
            Account__c = acc.Id,
            Destination__c = 'Vienne',
            Start_Date__c = Date.today().addDays(5),
            End_Date__c = Date.today().addDays(10)
        );
        insert trip;
    }

    @isTest
    static void accountSelector_selectByIds_returnsMatchingAccounts() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Account> results = new AccountSelector().selectByIds(new Set<Id>{ acc.Id });
        System.assertEquals(1, results.size());
    }

    @isTest
    static void contractSelector_selectByIds_returnsMatchingContracts() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        List<Contract> results = new ContractSelector().selectByIds(new Set<Id>{ contract.Id });
        System.assertEquals(1, results.size());
    }

    @isTest
    static void opportunitySelector_selectByIds_returnsMatchingOpportunities() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Opportunity> results = new OpportunitySelector().selectByIds(new Set<Id>{ opp.Id });
        System.assertEquals(1, results.size());
    }

    @isTest
    static void tripSelector_selectByIds_returnsMatchingTrips() {
        Trip__c trip = [SELECT Id FROM Trip__c LIMIT 1];
        List<Trip__c> results = new TripSelector().selectByIds(new Set<Id>{ trip.Id });
        System.assertEquals(1, results.size());
    }

    @isTest
    static void tripSettingsSelector_selectDefault_returnsConfiguredThresholds() {
        Trip_Settings__mdt settings = new TripSettingsSelector().selectDefault();
        System.assertEquals(10, settings.Min_Participants__c);
        System.assertEquals(7, settings.Days_Before_Departure__c);
    }
}
