/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 15/09/2021
 * @description HDT_TRH_CampaignMember Test Classes
 * @history Fabricio Petkevicius Nunes – 15/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_CampaignMemberTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@isTest
	public static void testTriggerSubscriptionBeforeAfterInsert(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;

		System.runAs(internalUser){

			test.startTest();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, true);
			List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(1, false);
			campaigns[0].Category__c='Campagna Outbound';
			campaigns[0].Channel__c='Bolletta';
			insert campaigns;

			List<CampaignMember> campMembers=HDT_UTL_DataFactoryTst.createCampaignMember(1, true, campaigns[0].Id, leads[0].Id, contacts[0].Id);

			test.stopTest();

			List<CampaignMember> tCampMembs=[SELECT Id
			                                 FROM CampaignMember
			                                 WHERE Id=:campMembers[0].Id];

			System.assertEquals(true, tCampMembs[0].Id!=null, 'Campaign Member not Inserted');
			System.assertNotEquals(false, tCampMembs[0].Id!=null, 'Campaign Member not Inserted');
		}
	}
}