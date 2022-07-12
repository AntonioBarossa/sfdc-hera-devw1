@IsTest
public with sharing class HDT_SCH_ActivityDispatcherSchedulerTst 
{
    @IsTest
    static void executeTst()
    {
        String cronoExpr  = '0 0 0 10 10 ?';
        Test.startTest();
            HDT_SCH_ActivityDispatcherScheduler activityDispatcher = new HDT_SCH_ActivityDispatcherScheduler();
            String jobId = System.schedule('activityDispatcher', cronoExpr, activityDispatcher);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(jobId), 'Schedulazione fallita');
    }
}
