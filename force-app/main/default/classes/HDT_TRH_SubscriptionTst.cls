/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 15/09/2021
 * @description HDT_TRH_Subscription Test Classes
 * @history Fabricio Petkevicius Nunes – 15/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_SubscriptionTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@isTest
	public static void testTriggerSubscriptionBeforeInsert(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserRoleId=HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_BACKOFFICE);
		insert internalUser;

		System.runAs(internalUser){

			test.startTest();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			// List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
            List<ServicePoint__c> servPoints = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            List<SBQQ__Subscription__c> subscriptions = HDT_UTL_DataFactoryTst.createSubscription(1, true, accounts[0].Id, contracts[0].Id, servPoints[0].Id);

			test.stopTest();

			List<SBQQ__Subscription__c> tSubs=[SELECT Id, CompanyOwner__c
			                          FROM SBQQ__Subscription__c
			                          WHERE Id=:subscriptions[0].Id];

			System.assertEquals(true, tSubs[0].CompanyOwner__c!=null, 'Subscription not Updated');
			System.assertNotEquals(false, tSubs[0].CompanyOwner__c!=null, 'Subscription not Updated');
		}
	}
}