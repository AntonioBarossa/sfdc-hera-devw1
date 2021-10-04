@isTest
public with sharing class HDT_WS_PaperlessTst {
    
    //CLASSE DI TEST COMMENTATA - RILEVATA CLASSE TARGET DEI TEST COME DEPRECATA.
    
    /*
    //DEBUG
    
    
    //DATA
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    //TESTS
    
    //execute
    @isTest
    private static void executeTest() {
        
        //SETUP
        SObject transition;
        SObject action;
        Case obj = [SELECT Id, Type FROM Case];
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('transition', transition);
        argsMap.put('action', action);
        argsMap.put('method', '');
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TESTING
        HDT_WS_Paperless myObjectToTest = new HDT_WS_Paperless();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = myObjectToTest.execute(argsMap);
        
        //ASSERTS
        
        
        
    }
    
    
    
    
    
    //WEBSERVICE MOCKS
    public class myWebServiceMock implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            if(isException){
                throw new AuraHandledException('Fake Exception for Tests');
            }
            
            HttpResponse response = new HttpResponse();
            
            HDT_WS_EngageOnePrint.HDT_WRP_ReponseObj bodyResp = new HDT_WS_EngageOnePrint.HDT_WRP_ReponseObj();
            
            if(isFailure){
                bodyResp.status = 'failure';
                bodyResp.message = 'Test_Message_Failure';
            } else {
                bodyResp.status = 'success';
                bodyResp.message = 'Test_Message_Success';
            }
            
            bodyResp.correlationId = '';
            bodyResp.timestamp = '';
            bodyResp.bodyBase64 = '';
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(bodyResp));
            response.setStatusCode(200);
            response.setStatus('OK');
            
            return response;
        }
    }
    
    
    
    */
}
