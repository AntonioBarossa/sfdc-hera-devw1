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
			HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
            
            Id pricebookId = Test.getStandardPricebookId();
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,false,accounts[0].id,sales,pricebookId);
            orders[0].VASBillingMode__c = 'E-Canone fisso';
            insert orders;
            
			List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].id, sales, orders[0].Id, contacts[0].Id);
			childOrders[0].RecordTypeId=defaultRt;
			childOrders[0].ProcessType__c='Prima Attivazione Ele';
            childOrders[0].Pricebook2Id = pricebookId;
            childOrders[0].VASBillingMode__c = 'E-Canone fisso';
			insert childOrders;
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id pointId = points[0].id;   
            
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,false);
            products[0].Family = 'VAS Fatturabili';
            insert products;
            Id productId = products[0].id; 
            
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);
            Id entryId = entries[0].id;
            
            HDT_UTL_DataFactoryTst.createOrderItem(10,true,childorders[0].id,pointId,productId,entryId);
         
            
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

			Map<String, Object> mapp = HDT_LC_ChildOrderProcess.controllerInit(tOrder.Id);
			
            Order tOrder2=[SELECT Id, Name, Sale__c
                          FROM Order 
                          WHERE Name='testChildOrderName'
                          LIMIT 1];
	            
			System.assertEquals(tOrder2.Sale__c, mapp.get('venditaId'), 'Return is empty');
			System.assertNotEquals(null, mapp, 'value of parameter is not matching');
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
            
            List<Order> ords = [Select id from Order WHERE Name='testOrderName0'];

			System.assertEquals(1, ords.size(), 'value of parameter is matching');
			System.assertNotEquals(null, ords, 'value of parameter is not matching');
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
			System.assertNotEquals(true, String.isEmpty(tResult.Id), 'value of parameter is not matching');
			Test.stopTest();
		}
	}
    
    @isTest static void testIsCommunity(){
        
         Map<String, Object> mapp = HDT_LC_ChildOrderProcess.isCommunity();
        
        System.assertEquals(false, mapp.get('isCommunity'), 'value of parameter is matching');
		System.assertNotEquals(null, mapp, 'value of parameter is not matching');
        
    }
}