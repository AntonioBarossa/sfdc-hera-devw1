/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 12/08/2021
 * @description HDT_LC_ChildOrderProcess for Test Classes
 * @history Fabricio Petkevicius Nunes – 12/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_ChildOrderProcessTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			Id defaultRt=constants.ORDER_RECORDTYPEID_DEFAULT;

			HDT_UTL_DataFactoryTst.pClickOrderPhase();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].id, 'Attiva');
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].id, 'Bozza');
			List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].id, sales, orders[0].Id, contacts[0].Id);
			childOrders[0].RecordTypeId=defaultRt;
			childOrders[0].ProcessType__c='Prima Attivazione Ele';
			insert childOrders;
		}
	}

	@isTest
	public static void testcontrollerInit(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			Order tOrder=[SELECT Id, Name
			              FROM Order 
			              WHERE Name='testChildOrderName'
			              LIMIT 1];

			Map<String, Object> tResult=HDT_LC_ChildOrderProcess.controllerInit(tOrder.Id);

			System.assertEquals(false, tResult.isEmpty(), 'Return is empty');
			System.assertNotEquals(true, tResult.isEmpty());
			Test.stopTest();
		}
	}

	@isTest
	public static void testsaveOption(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			Order tOrder=[SELECT Id, Name
			              FROM Order 
			              WHERE Name='testChildOrderName'
			              LIMIT 1];

			Order tOrderParent=[SELECT Id, Name
			                    FROM Order 
			                    WHERE Name='testOrderName0'
			                    LIMIT 1];

			HDT_LC_ChildOrderProcess.saveOption(tOrder.Id, 'Prima Attivazione Ele', tOrderParent.Id);

			//Class doesn't have a return, can't Assert
			//System.assertEquals(false, tResult.isEmpty(), 'Return is empty');
			//System.assertNotEquals(true, tResult.isEmpty());
			Test.stopTest();
		}
	}

	@isTest
	public static void testrefreshOrderChild(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			Order tOrder=[SELECT Id, Name
			              FROM Order 
			              WHERE Name='testChildOrderName'
			              LIMIT 1];

			Order tResult=HDT_LC_ChildOrderProcess.refreshOrderChild(tOrder.Id);

			System.debug('tResult = '+tResult);

			System.assertEquals(false, String.isEmpty(tResult.Id), 'Return is empty');
			System.assertNotEquals(true, String.isEmpty(tResult.Id));
			Test.stopTest();
		}
	}
}