@isTest
public with sharing class HDT_SCH_PublicValidationTst {
    @isTest
    public static void executeTst()  {
        Test.StartTest();
		HDT_SCH_PublicValidation testsche = new HDT_SCH_PublicValidation();
		String sch = '0 0 23 * * ?';
        System.schedule('Test status Check', sch, testsche );
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'Expecting one scheduled job');
        System.assertNotEquals(0, jobsScheduled.size(), 'Expecting one scheduled job, not 0');
        Test.stopTest();
    }
}
