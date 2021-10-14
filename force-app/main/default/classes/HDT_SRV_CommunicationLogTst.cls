/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 02/09/2021
 * @description HDT_SRV_CommunicationLog Test Classes
 * @history Fabricio Petkevicius Nunes – 02/09/2021 – Created class
 */
@isTest
public with sharing class HDT_SRV_CommunicationLogTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_SRV_CommunicationLog commLogSrv=new HDT_SRV_CommunicationLog();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);
		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;
	}

	@isTest
	public static void testCheckCreateAccess(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			commLogSrv.checkCreateAccess('Causale__c');

			// Void Method
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');

			Test.stopTest();
		}
	}

	@isTest
	public static void testCeateRecords(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
		List<CommunicationLog__c> commLogs=HDT_UTL_DataFactoryTst.createCommunicationLog(1, false, accounts[0].Id, contacts[0].Id);

		System.runAs(tUser){

			Test.startTest();

			List<CommunicationLog__c> testCeateRecords=commLogSrv.createRecords(commLogs);

			System.assertEquals(false, testCeateRecords.isEmpty(), 'Communication Log not Created');
			System.assertNotEquals(true, testCeateRecords.isEmpty(), 'Value of parameter is not matching');

			Test.stopTest();
		}
	}
}