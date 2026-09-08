@isTest
private class TripSchedulersTest {
    @isTest
    static void tripAutoCancelScheduler_schedulesUnderlyingBatch() {
        Test.startTest();
        String jobId = System.schedule('TripAutoCancelSchedulerTest', '0 0 2 * * ?', new TripAutoCancelScheduler());
        Test.stopTest();

        System.assertNotEquals(null, jobId);
    }

    @isTest
    static void tripStatusUpdateScheduler_schedulesUnderlyingBatch() {
        Test.startTest();
        String jobId = System.schedule('TripStatusUpdateSchedulerTest', '0 15 2 * * ?', new TripStatusUpdateScheduler());
        Test.stopTest();

        System.assertNotEquals(null, jobId);
    }
}
