/**
 * Batch quotidien GGT-05 : recalcule le statut de chaque Trip__c non annulé
 * ("À venir" / "En cours" / "Terminé") selon la position d'aujourd'hui par rapport
 * à ses dates. Les Trip__c déjà "Annulé" sont exclus dès la requête et ne sont
 * jamais réécrits par ce batch.
 */
public with sharing class TripStatusUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {
    private final TripSelector tripSelector = new TripSelector();
    private final TripService tripService = new TripService();
    private Integer updatedTripCount = 0;

    /**
     * Charge tous les Trip__c non annulés, candidats au recalcul de statut.
     */
    public List<Trip__c> start(Database.BatchableContext context) {
        return tripSelector.selectActiveForStatusRecalculation();
    }

    /**
     * Recalcule le statut du lot reçu et ne met à jour que les Trip__c dont le
     * statut calculé diffère du statut actuel (évite les DML inutiles).
     */
    public void execute(Database.BatchableContext context, List<Trip__c> scope) {
        List<Trip__c> tripsWithChangedStatus = new List<Trip__c>();

        for (Trip__c trip : scope) {
            String computedStatus = tripService.computeStatusForDates(trip.Start_Date__c, trip.End_Date__c);
            if (computedStatus != trip.Status__c) {
                trip.Status__c = computedStatus;
                tripsWithChangedStatus.add(trip);
            }
        }

        tripService.updateTrips(tripsWithChangedStatus);
        updatedTripCount += tripsWithChangedStatus.size();
    }

    /**
     * Journalise le nombre total de Trip__c dont le statut a été mis à jour par cette exécution.
     */
    public void finish(Database.BatchableContext context) {
        System.debug(LoggingLevel.INFO, 'TripStatusUpdateBatch (GGT-05) : ' + updatedTripCount + ' Trip__c mis à jour.');
    }
}
