/**
 * Header of the class "HDT_SCH_ChiusuraForzataCreditCheckTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_SCH_ChiusuraForzataCreditCheck"
 * @history
 * @Created 22/09/2021
 * Modified By:
 **/

@isTest
public class HDT_SCH_ChiusuraForzataCreditCheckTst {
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('PraxidiaIntegration','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
            
            ForzaturaChiusuraCreditCheck__c fo = new ForzaturaChiusuraCreditCheck__c(
            	LAST_N_DAYS__c = 12,
                Name='test'              	
            );
            
            insert fo;
        }
     }

  @isTest
	static void test1(){

        String CRON_EXP = '20 30 8 10 2 ?';
        
        Test.startTest();
        HDT_SCH_ChiusuraForzataCreditCheck cf = new HDT_SCH_ChiusuraForzataCreditCheck();
        String jobID = System.schedule('Label of the job', CRON_EXP , cf);
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
    }
}