@IsTest
public with sharing class HDT_SCH_InvioNumerazioniTst 
{
    @isTest 
    static void scheduleTest()
    {
        String cronExpr = '0 0 0 10 10 ?';
        Test.startTest();
            HDT_SCH_InvioNumerazioni invioNumerazioni = new HDT_SCH_InvioNumerazioni();
            String jobId = System.schedule('invioNumerazioni', cronExpr, invioNumerazioni);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(jobId),'Schedulazione fallita');
    }
}
