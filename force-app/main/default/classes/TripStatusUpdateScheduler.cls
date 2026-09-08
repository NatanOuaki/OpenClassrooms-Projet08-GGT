/**
 * Planifie l'exécution quotidienne de TripStatusUpdateBatch (GGT-05).
 */
public with sharing class TripStatusUpdateScheduler implements Schedulable {
    /**
     * Lance TripStatusUpdateBatch avec une taille de lot explicite.
     */
    public void execute(SchedulableContext context) {
        Database.executeBatch(new TripStatusUpdateBatch(), 200);
    }
}
