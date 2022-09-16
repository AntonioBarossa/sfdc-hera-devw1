/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 26/08/2021
 * @description Test Class for HDT_QR_Order.cls
 * @history Fabricio Petkevicius Nunes – 26/08/2021 – Created class
 */
@isTest
public class HDT_QR_OrderTst{
	private static HDT_QR_Order orderQr=new HDT_QR_Order();
	private static HDT_UTL_Constants utlConstants=new HDT_UTL_Constants();
	@TestSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
		accounts[0].ActiveMonitoring__c=true;
		insert accounts;

		List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
		List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(2, true, accounts[0].Id, 'Attiva');
		List<Pricebook2> pricebook=HDT_UTL_DataFactoryTst.createPricebook(1, true);
		List<Order> orders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(2, false, accounts[0].Id, sales, pricebook[0].Id);
		id orderdossier=utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
		orders[1].RecordTypeId=orderdossier;
		orders[0].Username__c='test';
		orders[0].Password__c='test1';
		insert orders;

		List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].Id, sales, orders[0].Id, contacts[0].Id);
		childOrders[0].QualityCall__c=true;
		insert childOrders;

		List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
		List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
		quotes[0].IsVAS__c=false;
		quotes[0].AmendmentAllowed__c=false;
		insert quotes;

		orders[0].ServicePoint__c=servPoints[0].Id;
		orders[0].SBQQ__Quote__c=quotes[0].id;
		update orders;
	}

	@isTest
	static void testgetRecordBySale(){

		Test.startTest();

		List<Sale__c> tSale=[SELECT Id, Status__c
		                     FROM Sale__c
		                     WHERE Status__c='Attiva'
		                     LIMIT 1];

		List<Order> getRecordBySale=orderQr.getRecordBySale(tSale[0].Id);

		Test.stopTest();

		System.assertEquals(false, getRecordBySale.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecordBySale.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrdersRecord(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Id> orderIds=new List<Id>();
		orderIds.add(tOrder[0].Id);

		Map<Id, Order> getOrdersRecord=orderQr.getOrdersRecord(orderIds);

		Test.stopTest();

		System.assertEquals(false, getOrdersRecord.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getOrdersRecord.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordBySaleFilterRecordTypeId(){

		Test.startTest();

		List<Sale__c> tSale=[SELECT Id, Status__c
		                     FROM Sale__c
		                     WHERE Status__c='Attiva'
		                     LIMIT 1];


		Id rt=utlConstants.ORDER_RECORDTYPEID_DEFAULT;

		List<Order> getRecordBySaleFilterRecordType=orderQr.getRecordBySaleFilterRecordTypeId(tSale[0].Id, rt);

		Test.stopTest();

		System.assertEquals(false, getRecordBySaleFilterRecordType.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecordBySaleFilterRecordType.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordById(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		Order getRecordById=orderQr.getRecordById(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getRecordById==null, 'Order not found');
		System.assertNotEquals(true, getRecordById==null, 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrderbyId(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		Order getOrderById=orderQr.getOrderbyId(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getOrderById==null, 'Order not found');
		System.assertNotEquals(true, getOrderById==null, 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrderByIdForSalesCallout(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getOrderByIdForSaleCallout=orderQr.getOrderByIdForSalesCallout(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getOrderByIdForSaleCallout.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getOrderByIdForSaleCallout.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordsByIds(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Id> orderIds=new List<Id>();
		orderIds.add(tOrder[0].Id);

		List<Order> getRecordsByIds=orderQr.getRecordsByIds(orderIds);

		Test.stopTest();

		System.assertEquals(false, getRecordsByIds.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecordsByIds.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetChildOrdersByParentId(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getChildOrdersByParentId=orderQr.getChildOrdersByParentId(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getChildOrdersByParentId.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getChildOrdersByParentId.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetChildOrdersByParentIds(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];


		List<String> orderIds=new List<String>();
		orderIds.add(tOrder[0].Id);
		List<Order> getChildOrdersByParentIds=orderQr.getChildOrdersByParentIds(orderIds);

		Test.stopTest();

		System.assertEquals(false, getChildOrdersByParentIds.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getChildOrdersByParentIds.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetChildOrdersByParentIdAllStatus(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getChildOrdersByParentIdAllStatus=orderQr.getChildOrdersByParentIdAllStatus(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getChildOrdersByParentIdAllStatus.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getChildOrdersByParentIdAllStatus.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordByIdFilterStatus(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getRecordByIdFilterStatus=orderQr.getRecordByIdFilterStatus(tOrder[0].Id, 'Draft');

		Test.stopTest();

		System.assertEquals(false, getRecordByIdFilterStatus.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecordByIdFilterStatus.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetActiveRecordsByAccountId(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		tOrder[0].Status='In Lavorazione';
		torder[0].ParentOrder__c=null;

		update tOrder;
		String acc = [SELECT Id FROM Account][0].id;
		                       
		List<Order> getActiveRecordsByAccountId=orderQr.getActiveRecordsByAccountId(acc);

		Test.stopTest();

		System.assertEquals(false, getActiveRecordsByAccountId.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getActiveRecordsByAccountId.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordsByAccountId(){

		Test.startTest();

		String acc = [SELECT Id FROM Account][0].id;
		List<Order> getRecordsbyAccountId=orderQr.getRecordsByAccountId(acc);

		Test.stopTest();

		System.assertEquals(false, getRecordsbyAccountId.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecordsbyAccountId.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetActiveRecordsByAccountIdNotParent(){

		Test.startTest();
		String acc = [SELECT Id FROM Account][0].id;
		List<Order> getActiveRecByAccIdNotParent=orderQr.getActiveRecordsByAccountIdNotParent(acc);

		Test.stopTest();

		System.assertEquals(false, getActiveRecByAccIdNotParent.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getActiveRecByAccIdNotParent.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordsForVasSelection(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name
		                    FROM Order 
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		tOrder[0].Status='In Lavorazione';

		update tOrder;
		String acc = [SELECT Id FROM Account][0].id;
		List<Order> getRecsForVasSaleSelection=orderQr.getRecordsForVasSelection(acc);

		Test.stopTest();

		System.assertEquals(false, getRecsForVasSaleSelection.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecsForVasSaleSelection.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordByOrderNumber(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name, OrderNumber
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getRecByOrderNumber=orderQr.getRecordByOrderNumber(tOrder[0].OrderNumber);

		Test.stopTest();

		System.assertEquals(false, getRecByOrderNumber.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecByOrderNumber.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordByOrderId(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name, OrderNumber
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getRecByOrderId=orderQr.getRecordByOrderId(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getRecByOrderId.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecByOrderId.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordsByOrdersIdsBulk(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name, OrderNumber
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<String> orderIds=new List<String>();
		orderIds.add(tOrder[0].Id);

		List<Order> getRecsByOrdersIdsBulk=orderQr.getRecordsByOrdersIdsBulk(orderIds);

		Test.stopTest();

		System.assertEquals(false, getRecsByOrdersIdsBulk.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecsByOrdersIdsBulk.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRoleNameByRoleId(){

		id userRoleId=HDT_UTL_DataFactoryTst.getUserRoleId(utlConstants.USERROLE_DEVELOPERNAME_BACKOFFICE);

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserRoleId=userRoleId;

		insert internalUser;
		
		System.runAs(internalUser){

			Test.startTest();

			String getRoleNamebyRoleId=orderQr.getRoleNameByRoleId();

			Test.stopTest();

			System.assertEquals(false, getRoleNamebyRoleId==null, 'User role not found');
			System.assertNotEquals(true, getRoleNamebyRoleId==null, 'Value of parameter is not matching');
		}
	}

	@isTest
	static void testgetDates(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name, OrderNumber
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		Order getDates=orderQr.getDates(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getDates==null, 'Order not found');
		System.assertNotEquals(true, getDates==null, 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordsByIdWithFields(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, Name, OrderNumber
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<String> orderIds=new List<String>();
		orderIds.add(tOrder[0].Id);

		List<Order> getRecsByIdWithFields=orderQr.getRecordsByIdWithFields(orderIds, 'Name, Status');

		Test.stopTest();

		System.assertEquals(false, getRecsByIdWithFields.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getRecsByIdWithFields.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrderCreatedYesterday(){

		List<Order> tOrder=[SELECT Id, Name, OrderNumber
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];


		Datetime yesterday=Datetime.now().addDays(-1);
		Test.setCreatedDate(tOrder[0].Id, yesterday);

		Test.startTest();

		List<Order> getOrderCreatedYesterday=orderQr.getOrderCreatedYesterday();

		Test.stopTest();

		System.assertEquals(false, getOrderCreatedYesterday.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getOrderCreatedYesterday.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetRecordTypesDeveloperNameById(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id, RecordTypeId
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		String getRecTypeDevNameById=HDT_QR_Order.getRecordTypesDeveloperNameById(tOrder[0].RecordTypeId);

		Test.stopTest();

		System.assertEquals(false, getRecTypeDevNameById==null, 'Order not found');
		System.assertNotEquals(true, getRecTypeDevNameById==null, 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrderForComfortQualityResult(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getOrderFromComfQualityResult=orderQr.getOrderForComfortQualityResult(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getOrderFromComfQualityResult.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getOrderFromComfQualityResult.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrderByUsernamePassword(){

		Test.startTest();

		List<Order> getOrderByUsernamePassword=orderQr.getOrderByUsernamePassword('test', 'test1');

		Test.stopTest();

		System.assertEquals(false, getOrderByUsernamePassword.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getOrderByUsernamePassword.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetChildOrdersDocumentalActivityByParentId(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getChildOrderDocActivityByParentId=orderQr.getChildOrdersDocumentalActivityByParentId(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getChildOrderDocActivityByParentId.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getChildOrderDocActivityByParentId.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrderForActiveMonitoringCheck(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getOrderForActiveMonitoringCheck=orderQr.getOrderForActiveMonitoringCheck(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getOrderForActiveMonitoringCheck.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getOrderForActiveMonitoringCheck.isEmpty(), 'Value of parameter is not matching');
	}

	@isTest
	static void testgetOrderForComfort(){

		Test.startTest();

		List<Order> tOrder=[SELECT Id
		                    FROM Order
		                    WHERE Name='testOrderName0'
		                    LIMIT 1];

		List<Order> getOrderForComfort=orderQr.getOrderForComfort(tOrder[0].Id);

		Test.stopTest();

		System.assertEquals(false, getOrderForComfort.isEmpty(), 'Order not found');
		System.assertNotEquals(true, getOrderForComfort.isEmpty(), 'Value of parameter is not matching');
	}
    
	@isTest static void testGetPodOrderFromQuote(){

        String quote =[SELECT Id FROM SBQQ__Quote__c][0].id;
		
		Test.startTest();
        
		List<Order> orders = orderQr.getPodOrderFromQuote(quote);

		Test.stopTest();

		System.assertEquals(1, orders.size(), 'Order not found');
		System.assertNotEquals(null, orders, 'Order not found');
	}
    
	@isTest static void testGetRecordsByAccountIdCopContrattoFirmato(){

        String acc = [SELECT Id FROM Account][0].id;
        
        Order ord = [Select id FROM Order WHERE Username__c='test'];
        ord.ContractSigned__c = true;
        ord.Status = 'In Lavorazione';
        update ord;
		
		Test.startTest();
        
		List<Order> orders = orderQr.getRecordsByAccountIdCopContrattoFirmato(acc);

		Test.stopTest();

		System.assertEquals(0, orders.size(), 'Order not found');
		System.assertNotEquals(null, orders, 'Order not found');
	}
    
    	@isTest static void testGetRecordsByAccountIdCopContrattoNonFirmato(){

        String acc = [SELECT Id FROM Account][0].id;
        
        Order ord = [Select id FROM Order WHERE Username__c='test'];
        ord.ContractSigned__c = false;
        ord.Status = 'In Lavorazione';
        update ord;
		
		Test.startTest();
        
		List<Order> orders = orderQr.getRecordsByAccountIdCopContrattoNonFirmato(acc);

		Test.stopTest();

		System.assertEquals(1, orders.size(), 'Order not found');
		System.assertNotEquals(null, orders, 'Order not found');
	}
    
	@isTest static void testGetRecordsByAccountIdCopContrattoSignatureMethod(){

        String acc = [SELECT Id FROM Account][0].id;
        
        Order ord = [Select id FROM Order WHERE Username__c='test'];
        ord.Status = 'In Lavorazione';
        ord.SignatureMethod__c = 'Cartacea';
        update ord;
		
		Test.startTest();
        
		List<Order> orders = orderQr.getRecordsByAccountIdCopContrattoSignatureMethod(acc, 'Cartacea');

		Test.stopTest();

		System.assertEquals(1, orders.size(), 'Order not found');
		System.assertNotEquals(null, orders, 'Order not found');
	}

	@isTest static void testGetOrderForComfortMethod(){

        Order ord = [Select id FROM Order WHERE Username__c='test'];
		
		Test.startTest();
        
		List<Order> orders = orderQr.getOrderForComfort(ord.Id);

		Test.stopTest();

		System.assertEquals(1, orders.size(), 'Order found');
		System.assertNotEquals(null, orders, 'Order found');
	}

	@isTest static void testGetOrdersListMethod(){

        Order ord = [Select id FROM Order WHERE Username__c='test'];
		
		Test.startTest();
        
		List<Order> orders = orderQr.getOrdersList(new List<String>{ord.Id});

		Test.stopTest();

		System.assertEquals(1, orders.size(), 'Order found');
		System.assertNotEquals(null, orders, 'Order found');
	}

	@isTest static void testGetOrdersByParentMethod(){

        List<Order> tOrder=[SELECT Id, Name FROM Order WHERE Name='testOrderName0' LIMIT 1];

		Test.startTest();
        
		Map<String, List<String>> orders = HDT_QR_Order.getOrdersByParent(new Set<String>{tOrder[0].Id});

		Test.stopTest();

		System.assertEquals(1, orders.size(), 'Order found');
		System.assertNotEquals(null, orders, 'Order found');

	}

}