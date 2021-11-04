/**
 * Header of the class "HDT_SCH_QueueAssignmentSchedulerTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_SCH_QueueAssignmentScheduler"
 * @history
 * @Created 24/09/2021
 * Modified By:
 **/

@isTest
public class HDT_SCH_QueueAssignmentSchedulerTst {
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('PraxidiaIntegration','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
                        
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountPartner(1,false,'AccountTest');
            for(Account a : accs){
                a.CompanyOwner__c='MMS';
            }
            insert accs;
            
        }
     }

  @isTest
	static void test1(){

        String CRON_EXP = '20 30 8 10 2 ?';
        
        List<Account> accs = [SELECT id from Account];
        
		Test.startTest();
        
        HDT_SCH_PraxidiaReclami prec = new HDT_SCH_PraxidiaReclami();
        System.schedule('xxxPartnerQueuesxxx', CRON_EXP , prec);
        
        HDT_SCH_QueueAssignmentScheduler qas = new HDT_SCH_QueueAssignmentScheduler(accs);
        System.schedule('Label of the job', CRON_EXP , qas);
        
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(2, jobsScheduled.size(), 'expecting two scheduled job');
        
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(2, jobsApexBatch.size(), 'expecting two apex batch job');
        
    }
}