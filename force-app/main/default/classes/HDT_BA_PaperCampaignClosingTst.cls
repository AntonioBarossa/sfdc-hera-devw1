/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 08/09/2021
 * @description HDT_BA_PaperCampaignClosing Test Classes
 * @history Luis Bispo – 08/09/2021 – Created class
 */
@isTest
public with sharing class HDT_BA_PaperCampaignClosingTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void setup(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		System.runAs(internalUser){

			List<Campaign> campaignList=HDT_UTL_DataFactoryTst.createCampaign(1, false);
			campaignList[0].Category__c='Campagna Outbound';
			campaignList[0].Channel__c='Bolletta';
			insert campaignList;

			List<Lead> leadList=HDT_UTL_DataFactoryTst.createLead(1, true);
			List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);

			List<PaperProcessing__c> paperProcessingList=HDT_UTL_DataFactoryTst.createPaperProcessing(1, false, 'TestPaperProc', campaignList[0].Id);
			paperProcessingList[0].Status__c='Bozza';
			insert paperProcessingList;

			List<CampaignMember> campaignMemberList=HDT_UTL_DataFactoryTst.createCampaignMember(1, false, campaignList[0].Id, leadList[0].Id, contactList[0].Id);
			campaignMemberList[0].PaperProcess__c=paperProcessingList[0].Id;
			insert campaignMemberList;
		}
	}

	@isTest
	static void testBatchPaperCampaignClosing(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			PaperProcessing__c tPaperProcessing=[SELECT Id
			                                     FROM PaperProcessing__c
			                                     WHERE Status__c='Bozza'
			                                     LIMIT 1];

			HDT_BA_PaperCampaignClosing bc=new HDT_BA_PaperCampaignClosing(tPaperProcessing.Id);

			DataBase.executeBatch(bc);

			Test.stopTest();

			System.assert(bc!=null);
			System.assertNotEquals(null, bc, 'HDT_BA_PaperCampaignClosing is null');
		}
	}
}