@isTest
public class HDT_LC_AccountDataEnrichmentTst {

    /*
        Test Class for:
        HDT_QR_AccountDataEnrichment        77%
        HDT_LC_AccountDataEnrichment        75%
        HDT_LC_AccountDataEnrichmentHelper  67%
        HDT_WRP_AccountDataEnrichment       0% 
    */

    @testSetup
    static void setup() {
        Account a = new Account();
        a.CustomerCode__c = '0001';
        a.Name = 'accountTest';
        insert a;
    }


    @isTest
    public static void getTableConfig(){

        HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj retObj;

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Test.startTest();
        retObj = HDT_LC_AccountDataEnrichment.getTableConfig(account.Id, 'cmor');
        retObj = HDT_LC_AccountDataEnrichment.getTableConfig(account.Id, 'null');
        Test.stopTest();
    }
    
    @isTest
    public static void testWebService() {

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        HDT_LC_AccountDataEnrichment controller = new HDT_LC_AccountDataEnrichment();
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)HDT_LC_AccountDataEnrichment.startRequest(account.Id, 'cmor');
        
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
        //system.assert(requests.get(controller.requestLabel) != null);
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');   
        // Set the fake response for the continuation     
        Test.setContinuationResponse('', response);
        // Invoke callback method
        Object result = Test.invokeContinuationMethod(controller, conti);
        // result is the return value of the callback
        System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.
        //System.assertEquals('Mock response body', controller.result);
    }

    
    @isTest
    public static void testWebService2() {

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        HDT_LC_AccountDataEnrichment controller = new HDT_LC_AccountDataEnrichment();
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)HDT_LC_AccountDataEnrichment.startRequest(account.Id, 'null');
        
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1);
        //system.assert(requests.get(controller.requestLabel) != null);
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');   
        // Set the fake response for the continuation     
        Test.setContinuationResponse('', response);
        // Invoke callback method
        Object result = Test.invokeContinuationMethod(controller, conti);
        // result is the return value of the callback
        System.assertEquals(null, result);
        // Verify that the controller's result variable
        //   is set to the mock response.
        //System.assertEquals('Mock response body', controller.result);
    }





}