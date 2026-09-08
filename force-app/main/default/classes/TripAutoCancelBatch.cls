/**
 * Batch quotidien GGT-04 : annule automatiquement les Trip__c partant dans
 * Days_Before_Departure__c jours (paramétrable via Trip_Settings__mdt) et comptant
 * moins de Min_Participants__c participants inscrits, en excluant les Trip__c
 * déjà annulés et ceux dont le nombre de participants est vide.
 */
public with sharing class TripAutoCancelBatch implements Database.Batchable<SObject>, Database.Stateful {
    private final TripSelector tripSelector = new TripSelector();
    private final TripSettingsSelector tripSettingsSelector = new TripSettingsSelector();
    private final TripService tripService = new TripService();
    private Integer cancelledTripCount = 0;

    /**
     * Charge les Trip__c candidats à l'auto-annulation, à partir du seuil et de la
     * fenêtre de jours configurés dans Trip_Settings__mdt.Default.
     */
    public List<Trip__c> start(Database.BatchableContext context) {
        Trip_Settings__mdt settings = tripSettingsSelector.selectDefault();
        Date targetDepartureDate = Date.today().addDays(Integer.valueOf(settings.Days_Before_Departure__c));
        return tripSelector.selectDepartingOnDateBelowMinParticipants(targetDepartureDate, settings.Min_Participants__c);
    }

    /**
     * Annule le lot de Trip__c reçu.
     */
    public void execute(Database.BatchableContext context, List<Trip__c> scope) {
        tripService.cancelTrips(scope);
        cancelledTripCount += scope.size();
    }

    /**
     * Journalise le nombre total de Trip__c annulés par cette exécution.
     */
    public void finish(Database.BatchableContext context) {
        System.debug(LoggingLevel.INFO, 'TripAutoCancelBatch (GGT-04) : ' + cancelledTripCount + ' Trip__c annulés.');
    }
}
