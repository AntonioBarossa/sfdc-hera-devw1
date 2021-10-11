/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 02/09/2021
 * @description HDT_TRH_PaperProcessing Test Classes
 * @history Fabricio Petkevicius Nunes – 02/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_PaperProcessingTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@isTest
	public static void testBeforeAfterInsertAndUpdate(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		System.runAs(internalUser){

			Test.startTest();

			// TEST INSERT --
			List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(1, true);
			List<PaperProcessing__c> paperProcs=HDT_UTL_DataFactoryTst.createPaperProcessing(1, false, 'tPaperProc', campaigns[0].Id);
			paperProcs[0].TriggerCustomerReport__c = false;

			insert paperProcs;

			// TEST UPDATE --
			List<PaperProcessing__c> paperProc=[SELECT Id, Name, Campaign__c, Status__c, LastDateReportClienti__c, TriggerCustomerReport__c
			                                    FROM PaperProcessing__c
			                                    WHERE Campaign__c=:campaigns[0].Id
			                                    LIMIT 1];

			paperProc[0].Status__c='Completata';
			paperProc[0].LastDateReportClienti__c=Date.today();
			paperProc[0].TriggerCustomerReport__c = true;

			update paperProc;

			Test.stopTest();

			// ASSERTS --
			List<PaperProcessing__c> updatedPaperProc=[SELECT Id, Name, Status__c
			                                           FROM PaperProcessing__c
			                                           WHERE Status__c='In Corso'
			                                           LIMIT 1];
			
			System.assertEquals('In Corso', updatedPaperProc[0].Status__c, 'PaperProcessing Not Updated');
			System.assertNotEquals('', updatedPaperProc[0].Status__c, 'PaperProcessing Not Updated');
		}
	}
}