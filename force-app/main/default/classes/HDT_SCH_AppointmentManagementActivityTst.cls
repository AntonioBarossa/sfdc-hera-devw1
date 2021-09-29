/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 27/09/2021
 * @description HDT_SCH_ComfortCallScheduler for Test Classes
 * @history Laureta Demishaj – 27/09/2021 – Created class
*/
@isTest
public with sharing class HDT_SCH_AppointmentManagementActivityTst {
    @isTest
    public static void executeTst()  {
        Test.StartTest();
		HDT_SCH_AppointmentManagementActivity testsche = new HDT_SCH_AppointmentManagementActivity();
		String sch = '0 0 23 * * ?';
        System.schedule('Test status Check', sch, testsche );
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'Expecting one scheduled job');
        System.assertNotEquals(0, jobsScheduled.size(), 'Expecting one scheduled job, not 0');
        Test.stopTest();
    }
}
