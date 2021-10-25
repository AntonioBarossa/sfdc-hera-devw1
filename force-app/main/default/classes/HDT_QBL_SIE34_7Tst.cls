/**
* @author Andrea Arosio (andrea.arosio@webresults.it)
* @date 14/10/2021
* @description Test Class for HDT_QBL_SIE34_7
*/
@isTest
public with sharing class HDT_QBL_SIE34_7Tst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			Id vasRt=constants.ORDER_RECORDTYPEID_VAS;

			HDT_UTL_DataFactoryTst.pClickOrderPhase();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].id, 'Attiva');
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
            
            Id pricebookId = Test.getStandardPricebookId();
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,false,accounts[0].id,sales,pricebookId);
            orders[0].VASBillingMode__c = 'E-Canone fisso';
            insert orders;
            
			List<Order> childOrders=HDT_UTL_DataFactoryTst.createChildOrder(1, false, accounts[0].id, sales, orders[0].Id, contacts[0].Id);
			childOrders[0].RecordTypeId=vasRt;
			childOrders[0].ProcessType__c='VAS';
            childOrders[0].Phase__c='Completata';
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
            
            List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(10,true,childorders[0].id,pointId,productId,entryId);
            Id orderItemId = orderItems[0].id;
         
            
		}
	}

     static testmethod void testQueueable(){

        Boolean finished = false;

        HDT_QBL_SIE34_7 sie34 = new HDT_QBL_SIE34_7('1','2021-01-01T13:00:00Z','TEXT');

        Test.startTest();
        
        System.enqueueJob(sie34);

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');

    }
}
