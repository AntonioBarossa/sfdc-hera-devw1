/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 15/09/2021
 * @description HDT_BA_PaperProcessing Test Classes
 * @history Fabricio Petkevicius Nunes – 15/09/2021 – Created class
 */
@isTest
public with sharing class HDT_BA_PaperProcessingTst{
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

			List<CampaignMember> campaignMemberList=HDT_UTL_DataFactoryTst.createCampaignMember(false, campaignList[0].Id, leadList, contactList);
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

			HDT_BA_PaperProcessing bc=new HDT_BA_PaperProcessing(new list<String>{tPaperProcessing.Id});

			DataBase.executeBatch(bc);

			Test.stopTest();

			ContentDocumentLink tDocLink=[SELECT Id, LinkedEntityId
			                              FROM ContentDocumentLink
			                              WHERE LinkedEntityId=:tPaperProcessing.Id];

			System.assertEquals(true, tDocLink.Id!=null, 'ContentDocumentLink not created');
			//System.assertNotEquals(false, tDocLink.Id!=null);
		}
	}
}