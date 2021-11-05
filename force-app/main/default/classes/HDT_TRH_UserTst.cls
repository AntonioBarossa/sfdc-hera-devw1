/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 13/09/2021
 * @description HDT_TRH_User Test Classes
 * @history Fabricio Petkevicius Nunes – 13/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_UserTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@isTest
	public static void testTriggerUserAfterInsert(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserRoleId=HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_BACKOFFICE);
		insert internalUser;

		System.runAs(internalUser){

			test.startTest();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			Id doorToDoorUserId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_DOOR2DOOR_PARTNER_NAME);
			HDT_UTL_DataFactoryTst.createCommunityUser(contacts[0], doorToDoorUserId, true);

			test.stopTest();

			List<Account> updatedAcc=[SELECT Id, Published__c
			                          FROM Account
			                          WHERE Id=:accounts[0].Id];

			System.assertEquals(true, updatedAcc[0].Published__c, 'Related Account not Updated');
			System.assertNotEquals(false, updatedAcc[0].Published__c, 'Related Account not Updated');
		}
	}
}