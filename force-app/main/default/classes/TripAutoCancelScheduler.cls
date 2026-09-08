/**
 * Planifie l'exécution quotidienne de TripAutoCancelBatch (GGT-04).
 */
public with sharing class TripAutoCancelScheduler implements Schedulable {
    /**
     * Lance TripAutoCancelBatch avec une taille de lot explicite.
     */
    public void execute(SchedulableContext context) {
        Database.executeBatch(new TripAutoCancelBatch(), 200);
    }
}
