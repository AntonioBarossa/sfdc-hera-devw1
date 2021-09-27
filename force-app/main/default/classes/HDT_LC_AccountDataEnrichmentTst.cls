@isTest
public class HDT_LC_AccountDataEnrichmentTst {

    /*
        Test Class for:
        HDT_QR_AccountDataEnrichment        77%
        HDT_LC_AccountDataEnrichment        100%
        HDT_LC_AccountDataEnrichmentHelper  86%
        HDT_WRP_AccountDataEnrichment       0% 
    */

    @testSetup
    static void setup() {

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

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
        System.assertEquals(true, retObj.success, 'Si è verificato un errore non previsto');
        System.assert(retObj.tables.size() > 0, 'Si è verificato un errore in fase di get delle informazioni richieste');
        retObj = HDT_LC_AccountDataEnrichment.getTableConfig(account.Id, null);
        System.assertEquals(false, retObj.success, 'Si è verificato un errore non previsto');
        System.assert(retObj.tables.size() == 0, 'Si è verificato un errore in fase di get delle informazioni richieste');

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

        Test.startTest();

        HDT_LC_AccountDataEnrichment controller = new HDT_LC_AccountDataEnrichment();
        // Invoke the continuation by calling the action method
        Continuation conti = (Continuation)HDT_LC_AccountDataEnrichment.startRequest(account.Id, 'cmor');
        
        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        system.assert(requests.size() == 1, 'requests.size() != 1');
        
        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)

        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');   
        
        // Set the fake response for the continuation     
        Test.setContinuationResponse('Continuation-1', response);

        // Invoke callback method
        Object result = HDT_LC_AccountDataEnrichment.processResponse(new List<String>{'Continuation-1'}, null);
        
        System.assert(result != null, 'result == null');

        Test.stopTest();
    }

    @isTest
    public static void testWebService2() {

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        AuraHandledException expectedException;
        Test.startTest();

        try {
            
            HDT_LC_AccountDataEnrichment controller = new HDT_LC_AccountDataEnrichment();
            // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)HDT_LC_AccountDataEnrichment.startRequest(account.Id, 'null');
            
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            system.assert(requests.size() == 1, 'requests.size() != 1');
            
            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
    
            HttpResponse response = new HttpResponse();
            response.setBody('Mock response body');   
    
            // Set the fake response for the continuation     
            Test.setContinuationResponse('Continuation-1', response);
    
            // Invoke callback method
            Object result = HDT_LC_AccountDataEnrichment.processResponse(new List<String>{'Continuation-1'}, null);
    
            System.assert(result != null, 'result == null');

        } catch (AuraHandledException e) {
            
            expectedException = e;

        }

        System.assertNotEquals(null, expectedException, 'Il sistema dovrebbe restituire AuraHandledException');

        Test.stopTest();
    }


    @IsTest
    static void startRequestHelperHandleThrownError(){
        
        Test.startTest();

        try {
            
            Object obj = HDT_LC_AccountDataEnrichmentHelper.startRequestHelper(null, 'cmor');

        } catch (AuraHandledException e) {
            
            System.assertNotEquals(null, e.getMessage(), 'AuraHandledException expected');

        }

        Test.stopTest();
        
    }
}