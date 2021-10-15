/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/09/2021
 * @description Test Class for HDT_SRV_Order.cls
 * @history Fabricio Petkevicius Nunes – 09/09/2021 – Created class
 */
@isTest
public class HDT_SRV_OrderTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_SRV_Order orderSrv=new HDT_SRV_Order();
	@TestSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickOrderPhase();
			HDT_UTL_DataFactoryTst.pClickInstance();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');
		}
	}

	@isTest
	static void testCheckAccessInit(){

		Boolean finished = false;

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			orderSrv.checkAccessInit('BillingCity__c, CommercialProduct__c', 'create');

			finished = true;

			Test.stopTest();

			// Method return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}

		System.assertEquals(true, finished, 'Test is not Ended');
	}

	@isTest
	static void testCheckReadAccess(){

		Boolean finished = false;

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			orderSrv.checkReadAccess('BillingCity__c, CommercialProduct__c');

			finished = true;

			Test.stopTest();

			// Method return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}

		System.assertEquals(true, finished, 'Test is not Ended');
	}

	@isTest
	static void testCheckCreateAccess(){

		Boolean finished = false;

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			orderSrv.checkCreateAccess('BillingCity__c, CommercialProduct__c');

			finished = true;

			Test.stopTest();

			// Method return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}
		System.assertEquals(true, finished, 'Test is not Ended');
	}

	@isTest
	static void testCheckUpdateAccess(){

		Boolean finished = false;

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			orderSrv.checkUpdateAccess('BillingCity__c, CommercialProduct__c');

			finished = true;

			Test.stopTest();

			// Method return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}

		System.assertEquals(true, finished, 'Test is not Ended');
	}

	@isTest
	static void testCreateRecord(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<Sale__c> tSale=[SELECT Id, Name
			                     FROM Sale__c 
			                     WHERE Name='testSaleName0'
			                     LIMIT 1];

			Id pricebookId=Test.getStandardPricebookId();

			List<Order> tOrders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, tAccount[0].Id, tSale, pricebookId);

			Order createdOrder=orderSrv.createRecord(tOrders[0]);

			Test.stopTest();

			System.assertEquals(true, createdOrder.Id!=null, 'Order not created');
			System.assertNotEquals(false, createdOrder.Id!=null, 'Order not created');
		}
	}

	@isTest
	static void testUpdateRecord(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<Sale__c> tSale=[SELECT Id, Name
			                     FROM Sale__c 
			                     WHERE Name='testSaleName0'
			                     LIMIT 1];

			Id pricebookId=Test.getStandardPricebookId();

			List<Order> tOrders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, true, tAccount[0].Id, tSale, pricebookId);
			tOrders[0].CommercialProduct__c='test';

			orderSrv.updateRecord(tOrders[0]);

			Test.stopTest();

			List<Order> updatedOrder=[SELECT Id, CommercialProduct__c
			                          FROM Order
			                          WHERE CommercialProduct__c='test'];

			System.assertEquals('test', updatedOrder[0].CommercialProduct__c, 'Order not Updated');
			System.assertNotEquals('', updatedOrder[0].CommercialProduct__c, 'Order not Updated');
		}
	}

	@isTest
	static void testUpdateRecords(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<Sale__c> tSale=[SELECT Id, Name
			                     FROM Sale__c 
			                     WHERE Name='testSaleName0'
			                     LIMIT 1];

			Id pricebookId=Test.getStandardPricebookId();

			List<Order> tOrders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, true, tAccount[0].Id, tSale, pricebookId);
			tOrders[0].CommercialProduct__c='test';

			orderSrv.updateRecords(tOrders);

			Test.stopTest();

			List<Order> updatedOrder=[SELECT Id, CommercialProduct__c
			                          FROM Order
			                          WHERE CommercialProduct__c='test'];

			System.assertEquals('test', updatedOrder[0].CommercialProduct__c, 'Order not Updated');
			System.assertNotEquals('', updatedOrder[0].CommercialProduct__c, 'Order not Updated');
		}
	}

	@isTest
	static void testGetRecordTypeIdOrderDossier(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			String dossierRecType=orderSrv.getRecordTypeIdOrderDossier();

			Test.stopTest();

			System.assertEquals(true, dossierRecType!=null, 'Dossier Record Type not retrieved');
			System.assertNotEquals(false, dossierRecType!=null, 'Dossier Record Type not retrieved');
		}
	}

	@isTest
	static void testGetRecordTypeIdDefault(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			String defaultRecType=orderSrv.getRecordTypeIdDefault();

			Test.stopTest();

			System.assertEquals(true, defaultRecType!=null, 'Default Record Type not retrieved');
			System.assertNotEquals(false, defaultRecType!=null, 'Default Record Type not retrieved');
		}
	}

	@isTest
	static void testgGetRecordTypeIdByDeveloperName(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			String getRecType=orderSrv.getRecordTypeIdByDeveloperName('HDT_RT_Attivazione');

			Test.stopTest();

			System.assertEquals(true, getRecType!=null, 'Record Type not retrieved');
			System.assertNotEquals(false, getRecType!=null, 'Record Type not retrieved');
		}
	}

	@isTest
	static void testAddBusinessDay(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			Date tBusinessDay=orderSrv.addBusinessDay(Date.today(), 5);

			Test.stopTest();

			Date tDate=Date.today().addDays(5);

			System.assertEquals(true, tBusinessDay>Date.today(), 'Date not updated');
			System.assertNotEquals(null, tBusinessDay, 'Date not updated');
		}
	}
}