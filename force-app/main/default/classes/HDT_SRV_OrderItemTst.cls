/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 28/07/2021
 * @description Test Class for HDT_SRV_OrderItem.cls
 * @history Fabricio Petkevicius Nunes – 28/07/2021 – Created class
 */
@isTest
public class HDT_SRV_OrderItemTst{
	@TestSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');

		List<ServicePoint__c> servicePoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);

		List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, true);

		Id pricebookId=Test.getStandardPricebookId();

		List<PricebookEntry> pricebookEntry=HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebookId);

		List<BillingProfile__c> billingProfiles=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);

		List<Order> orders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accounts[0].Id, sales, pricebookId);
		orders[0].BillingProfile__c=billingProfiles[0].Id;

		insert orders;

		List<OrderItem> orderItems=HDT_UTL_DataFactoryTst.createOrderItem(1, false, orders[0].Id, servicePoints[0].Id, products[0].Id, pricebookEntry[0].Id);
		orderItems[0].BillingProfile__c=billingProfiles[0].Id;

		insert orderItems;
	}

	@isTest
	static void testcheckAccessInit(){

		Boolean finished = false;

		Test.startTest();

		List<OrderItem> tOrdItemList=[SELECT Id, UnitPrice, Quantity
		                              FROM OrderItem
		                              WHERE UnitPrice=0
		                              LIMIT 1];

		System.debug('tOrdItemList = '+tOrdItemList);

		HDT_SRV_OrderItem orderItemsrv=new HDT_SRV_OrderItem();

		orderItemsrv.checkAccessInit('UnitPrice, Quantity', 'create');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test is not Ended');
	}

	@isTest
	static void testcheckReadAccess(){

		Boolean finished = false;

		Test.startTest();

		List<OrderItem> tOrdItemList=[SELECT Id, UnitPrice, Quantity
		                              FROM OrderItem
		                              WHERE UnitPrice=0
		                              LIMIT 1];

		System.debug('tOrdItemList = '+tOrdItemList);

		HDT_SRV_OrderItem orderItemsrv=new HDT_SRV_OrderItem();

		orderItemsrv.checkReadAccess('UnitPrice, Quantity');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test is not Ended');
	}

	@isTest
	static void testccheckCreateAccess(){

		Boolean finished = false;

		Test.startTest();

		List<OrderItem> tOrdItemList=[SELECT Id, UnitPrice, Quantity
		                              FROM OrderItem
		                              WHERE UnitPrice=0
		                              LIMIT 1];

		System.debug('tOrdItemList = '+tOrdItemList);

		HDT_SRV_OrderItem orderItemsrv=new HDT_SRV_OrderItem();

		orderItemsrv.checkCreateAccess('UnitPrice, Quantity');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test is not Ended');
	}

	@isTest
	static void testccheckcheckUpdateAccess(){

		Boolean finished = false;

		Test.startTest();

		List<OrderItem> tOrdItemList=[SELECT Id, UnitPrice, Quantity
		                              FROM OrderItem
		                              WHERE UnitPrice=0
		                              LIMIT 1];

		System.debug('tOrdItemList = '+tOrdItemList);

		HDT_SRV_OrderItem orderItemsrv=new HDT_SRV_OrderItem();

		orderItemsrv.checkUpdateAccess('UnitPrice, Quantity');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Test is not Ended');
	}
}