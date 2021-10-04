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
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){
                        
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,false,accId,'Bozza');
            for(Order o : orders){
                o.CustomerLastName__c = 'test';
            }
            insert orders;
            Id orderId = orders[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,true,accId);
            Id contactId = contacts[0].id;
            
            List<ServicePoint__c> servPoints = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id servPointId = servPoints[0].id;
            
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
        
        HDT_WS_Response res = new HDT_WS_Response();
        
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