@isTest
private class LifecycleEndToEndTest {
    @TestSetup
    static void setup() {
        insert new Account(Name = 'Ecole Cycle De Vie');
    }

    private static Trip_Settings__mdt getSettings() {
        return [SELECT Min_Participants__c, Days_Before_Departure__c FROM Trip_Settings__mdt WHERE DeveloperName = 'Default' LIMIT 1];
    }

    private static Opportunity createProspectingOpportunity(
        String destination,
        Date startDate,
        Date endDate,
        Decimal participants
    ) {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        return TestDataFactory.createTripOpportunity(
            acc.Id,
            'Voyage ' + destination,
            'Prospecting',
            9000,
            destination,
            startDate,
            endDate,
            participants
        );
    }

    private static void markAsClosedWon(List<Opportunity> opportunities) {
        for (Opportunity opportunity : opportunities) {
            opportunity.StageName = 'Closed Won';
        }
        update opportunities;
    }

    private static Trip__c findTripOf(Opportunity opportunity) {
        return [
            SELECT Status__c, Destination__c, Total_Cost__c, Number_of_Participants__c, Start_Date__c, End_Date__c
            FROM Trip__c
            WHERE Opportunity__c = :opportunity.Id
        ];
    }

    private static void runNightlyAutoCancelBatch() {
        TripAutoCancelBatch batch = new TripAutoCancelBatch();
        batch.execute(null, batch.start(null));
        batch.finish(null);
    }

    private static void runNightlyStatusUpdateBatch() {
        TripStatusUpdateBatch batch = new TripStatusUpdateBatch();
        batch.execute(null, batch.start(null));
        batch.finish(null);
    }

    @isTest
    static void signedOpportunity_createsTrip_thenTripProgressesFromUpcomingToOngoingToCompleted() {
        Opportunity opportunity = createProspectingOpportunity('Lisbonne', Date.today().addDays(30), Date.today().addDays(35), 20);

        markAsClosedWon(new List<Opportunity>{ opportunity });

        Trip__c trip = findTripOf(opportunity);
        System.assertEquals('À venir', trip.Status__c);
        System.assertEquals('Lisbonne', trip.Destination__c);
        System.assertEquals(9000, trip.Total_Cost__c);
        System.assertEquals(20, trip.Number_of_Participants__c);

        runNightlyStatusUpdateBatch();
        System.assertEquals('À venir', findTripOf(opportunity).Status__c, 'Un voyage futur reste à venir.');

        trip.Start_Date__c = Date.today();
        trip.End_Date__c = Date.today().addDays(5);
        update trip;
        runNightlyStatusUpdateBatch();
        System.assertEquals('En cours', findTripOf(opportunity).Status__c, 'Le jour du départ, le voyage est en cours.');

        trip.Start_Date__c = Date.today().addDays(-10);
        trip.End_Date__c = Date.today().addDays(-1);
        update trip;
        runNightlyStatusUpdateBatch();
        System.assertEquals('Terminé', findTripOf(opportunity).Status__c, 'Après la date de fin, le voyage est terminé.');
    }

    @isTest
    static void underfilledSignedTrip_isCancelledSevenDaysBeforeDeparture_thenIgnoredByStatusRecalculation() {
        Trip_Settings__mdt settings = getSettings();
        Date departureDate = Date.today().addDays(Integer.valueOf(settings.Days_Before_Departure__c));
        Opportunity opportunity = createProspectingOpportunity(
            'Berlin',
            departureDate,
            departureDate.addDays(4),
            settings.Min_Participants__c - 4
        );
        markAsClosedWon(new List<Opportunity>{ opportunity });
        System.assertEquals('À venir', findTripOf(opportunity).Status__c);

        runNightlyAutoCancelBatch();
        System.assertEquals('Annulé', findTripOf(opportunity).Status__c, 'Sous le seuil à J-7, le voyage est annulé.');

        Trip__c cancelledTrip = findTripOf(opportunity);
        cancelledTrip.Start_Date__c = Date.today().addDays(-20);
        cancelledTrip.End_Date__c = Date.today().addDays(-10);
        update cancelledTrip;
        runNightlyStatusUpdateBatch();
        System.assertEquals('Annulé', findTripOf(opportunity).Status__c, 'Un voyage annulé n est jamais recalculé.');
    }

    @isTest
    static void bulkOfSignedOpportunities_createsOnlyValidTrips_andCancelsOnlyUnderfilledOnes() {
        Trip_Settings__mdt settings = getSettings();
        Date departureDate = Date.today().addDays(Integer.valueOf(settings.Days_Before_Departure__c));
        Opportunity fullOpportunity = createProspectingOpportunity('Madrid', departureDate, departureDate.addDays(3), settings.Min_Participants__c + 10);
        Opportunity underfilledOpportunity = createProspectingOpportunity('Vienne', departureDate, departureDate.addDays(3), settings.Min_Participants__c - 3);
        Opportunity incompleteOpportunity = createProspectingOpportunity('Prague', null, null, 15);

        markAsClosedWon(new List<Opportunity>{ fullOpportunity, underfilledOpportunity, incompleteOpportunity });
        runNightlyAutoCancelBatch();
        runNightlyStatusUpdateBatch();

        System.assertEquals(2, [SELECT COUNT() FROM Trip__c], 'L Opportunity sans dates ne donne pas de voyage.');
        System.assertEquals('À venir', findTripOf(fullOpportunity).Status__c);
        System.assertEquals('Annulé', findTripOf(underfilledOpportunity).Status__c);
        System.assertEquals(0, [SELECT COUNT() FROM Trip__c WHERE Opportunity__c = :incompleteOpportunity.Id]);
    }
}
