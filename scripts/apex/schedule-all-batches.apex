// Planifie les deux batchs quotidiens GGT-04 et GGT-05.
// TripAutoCancelScheduler à 01h00 puis TripStatusUpdateScheduler à 01h15,
// pour laisser le temps au premier batch de finir avant que le second
// n'exclue les Trip__c qui viennent d'être annulés.
// À exécuter manuellement (sf apex run --file scripts/apex/schedule-all-batches.apex)
// quand l'activation des schedules est souhaitée.

System.schedule('TripAutoCancelScheduler - GGT-04', '0 0 1 * * ?', new TripAutoCancelScheduler());
System.schedule('TripStatusUpdateScheduler - GGT-05', '0 15 1 * * ?', new TripStatusUpdateScheduler());
