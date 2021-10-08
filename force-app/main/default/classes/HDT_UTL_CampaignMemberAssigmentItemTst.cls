/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 17/08/2021
 * @description HDT_UTL_CampaignMemberAssigmentItem Test Class
 * @history Fabricio Petkevicius Nunes – 17/08/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_CampaignMemberAssigmentItemTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<CampaignMemberAssigment__c> campMembAssigs=HDT_UTL_DataFactoryTst.createCampaignMemberAssigment(1, true, true, 'CampaignMemberAssigmentNameTest');
		}
	}

	@isTest
	public static void testcreateCampaignMemberAssigmentItem(){

		User tUser=[SELECT Id, FirstName, Email
		            FROM User
		            WHERE Email='crmuser@test.com'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccs=[SELECT Id, Name
			                     FROM Account 
			                     WHERE Name='test account0'];

			List<CampaignMemberAssigment__c> tCampMembAssig=[SELECT Id, Name
			                                                 FROM CampaignMemberAssigment__c 
			                                                 WHERE Name='CampaignMemberAssigmentNameTest'
			                                                 LIMIT 1];

			List<CampaignMemberAssigmentItem__c> campMemAssigItens=HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, false, tAccs[0].Id, tCampMembAssig[0].Id, 'Preview', 30);

			HDT_UTL_CampaignMemberAssigmentItem.createCampaignMemberAssigmentItem(campMemAssigItens);

			Test.stopTest();

			System.assertEquals(false, campMemAssigItens[0].Id!=null, 'Campaign Member Assignment Item not created');
			System.assertNotEquals(true, campMemAssigItens[0].Id!=null, 'Campaign Member Assignment Item not created');
		}
	}

	@isTest
	public static void testupdateCampaignMemberAssigmentItem(){

		User tUser=[SELECT Id, FirstName, Email
		            FROM User
		            WHERE Email='crmuser@test.com'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccs=[SELECT Id, Name
			                     FROM Account 
			                     WHERE Name='test account0'];

			List<CampaignMemberAssigment__c> tCampMembAssig=[SELECT Id, Name
			                                                 FROM CampaignMemberAssigment__c 
			                                                 WHERE Name='CampaignMemberAssigmentNameTest'
			                                                 LIMIT 1];

			List<CampaignMemberAssigmentItem__c> campMemAssigItens=HDT_UTL_DataFactoryTst.createCampaignMemberAssigmentItem(1, true, tAccs[0].Id, tCampMembAssig[0].Id, 'Preview', 30);

			campMemAssigItens[0].PercentageAllocation__c=500;

			HDT_UTL_CampaignMemberAssigmentItem.updateCampaignMemberAssigmentItem(campMemAssigItens);

			Test.stopTest();

			System.assertEquals(500, campMemAssigItens[0].PercentageAllocation__c, 'Campaign Member Assignment Item not Updated');
			System.assertNotEquals(0, campMemAssigItens[0].PercentageAllocation__c, 'Campaign Member Assignment Item not Updated');
		}
	}
}