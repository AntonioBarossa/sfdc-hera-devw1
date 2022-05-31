/**
 * Header of the class "HDT_WS_MotoreVasTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_MotoreVas"
 * @history
 * @Created 28/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_MotoreVasTst {

	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
                        
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
            Id accId = accs[0].id;

            Id pricebookId = Test.getStandardPricebookId();
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].id, 'Bozza');

            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accs[0].id, sales, pricebookId);
            for(Order o : orders){
                o.CustomerLastName__c = 'test';
                o.CommercialProduct__c = 'test';
            }
            insert orders;
            Id orderId = orders[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,true,accId);
            Id contactId = contacts[0].id;
            
            List<ServicePoint__c> servPoints = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id servPointId = servPoints[0].id;

            List<Product2> prods = HDT_UTL_DataFactoryTst.createProduct2(1, false);
            prods[0].DescriptionSAP__c = 'HERA CALDAIA SICURA FAMIGLIEV3';
            prods[0].IVA__c = 22.00;
            insert prods;

            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(prods, true, pricebookId);

            List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(2, false, orders[0].id, servPoints[0].id, prods[0].id, entries[0].id);
            orderItems[0].SBQQ__RequiredBy__c = orderItems[1].Id;
            orderItems[0].Quantity = 1;
            orderItems[0].ListPrice = 0.00;
            orderItems[0].UnitPrice = 0.00;
            insert orderItems;
            System.debug('************* orderItems: ' + orderItems);

            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
            Id contractId = contracts[0].id;
            
            List<Case> cases = HDT_UTL_DataFactoryTst.createCaseMorosita(1,false,accId,contactId,servPointId,contractId,orderId);
            for(Case c : cases){
                c.Order__c = orderId;
            }
            insert cases;
        
        }
     }

  @isTest
	static void testActivationCallout(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VAS.Activation','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        List <Order> orders = [Select id from Order];

        HDT_WS_ArrichmentDataEntityResponse res = new HDT_WS_ArrichmentDataEntityResponse();
        
        Test.startTest();
        
        res = HDT_WS_MotoreVas.activationCallout(orders[0].id);
        
        Test.stopTest();
        
        System.assertEquals(null, res.body, 'The body should be null since the mock is not instantiated');
        
        System.assertNotEquals(null, res, 'The response is not correctly returned');
        
    }
    
    @isTest
	static void testDeactivationCallout(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('VAS.Deactivation','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        List <Case> cases = [Select id from Case];
        
        HDT_WS_Response res = new HDT_WS_Response();
        
        Test.startTest();
        
        res = HDT_WS_MotoreVas.deactivationCallout(cases[0].id);
        
        Test.stopTest();
        
        System.assertEquals(null, res.body, 'The body should be null since the mock is not instantiated');
        
        System.assertNotEquals(null, res, 'The response is not correctly returned');
        
    }
}