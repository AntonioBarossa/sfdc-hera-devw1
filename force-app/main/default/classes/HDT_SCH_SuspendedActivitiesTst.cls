/**
 * @author Sabina Levonja (sabina.levonja@dunegroup.it)
 * @date 23/09/2021
 * @description HDT_SCH_SuspendedActivities Test Class
 * @history Sabina Levonja – 23/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_SCH_SuspendedActivitiesTst {
    @isTest
	static void testJob(){

        String cron = '0 0 0 10 10 ?';

        Test.startTest();
        HDT_SCH_SuspendedActivities sAct = new HDT_SCH_SuspendedActivities();
        System.schedule('Job', cron , sAct);
        Test.stopTest();

        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');

        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');

    }
}