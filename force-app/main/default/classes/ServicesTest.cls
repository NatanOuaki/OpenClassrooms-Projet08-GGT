@isTest
private class ServicesTest {
    @isTest
    static void accountService_createAccounts_insertsRecords() {
        List<Account> accounts = new List<Account>{ new Account(Name = 'Nouveau Compte Service') };
        new AccountService().createAccounts(accounts);
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Name = 'Nouveau Compte Service']);
    }

    @isTest
    static void accountService_createAccounts_doesNothingWhenEmpty() {
        new AccountService().createAccounts(new List<Account>());
        System.assertEquals(0, [SELECT COUNT() FROM Account]);
    }

    @isTest
    static void contractService_createContracts_insertsRecords() {
        Account acc = new Account(Name = 'Compte Contrat Service');
        insert acc;
        List<Contract> contracts = new List<Contract>{
            new Contract(AccountId = acc.Id, StartDate = Date.today(), ContractTerm = 12)
        };
        new ContractService().createContracts(contracts);
        System.assertEquals(1, [SELECT COUNT() FROM Contract WHERE AccountId = :acc.Id]);
    }

    @isTest
    static void contractService_createContracts_doesNothingWhenEmpty() {
        new ContractService().createContracts(new List<Contract>());
        System.assertEquals(0, [SELECT COUNT() FROM Contract]);
    }

    @isTest
    static void opportunityService_createOpportunities_insertsRecords() {
        Account acc = new Account(Name = 'Compte Opp Service');
        insert acc;
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(Name = 'Opp Service', AccountId = acc.Id, StageName = 'Prospecting', CloseDate = Date.today())
        };
        new OpportunityService().createOpportunities(opportunities);
        System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE AccountId = :acc.Id]);
    }

    @isTest
    static void opportunityService_createOpportunities_doesNothingWhenEmpty() {
        new OpportunityService().createOpportunities(new List<Opportunity>());
        System.assertEquals(0, [SELECT COUNT() FROM Opportunity]);
    }

    @isTest
    static void tripService_updateTrips_doesNothingWhenEmpty() {
        new TripService().updateTrips(new List<Trip__c>());
        System.assertEquals(0, [SELECT COUNT() FROM Trip__c]);
    }

    @isTest
    static void tripService_cancelTrips_doesNothingWhenEmpty() {
        new TripService().cancelTrips(new List<Trip__c>());
        System.assertEquals(0, [SELECT COUNT() FROM Trip__c]);
    }
}
