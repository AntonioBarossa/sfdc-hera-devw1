/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 23/09/2021
* @description HDT_SCH_LeadExpiredScheduler for Test Classes
* @history Elfrida Kora – 23/09/2021 – Created class
*/

@IsTest
public class HDT_SCH_LeadExpiredSchedulerTst {
    
     @TestSetup
    static void myData() 
    {
        
          HDT_UTL_DataFactoryTst.createLead(1, true);
        
        }
    
    @isTest
	static void test1(){

        String CRON_EXP = '20 30 8 10 2 ?';

        Test.startTest();
        HDT_SCH_LeadExpiredScheduler le = new HDT_SCH_LeadExpiredScheduler();
        System.schedule('Label of the job', CRON_EXP , le);
        Test.stopTest();

        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertNotEquals(0, jobsScheduled.size(),'not expecting scheduled job');
        

        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertNotEquals(0, jobsScheduled.size(),'not expecting apex batch job');


    }


}