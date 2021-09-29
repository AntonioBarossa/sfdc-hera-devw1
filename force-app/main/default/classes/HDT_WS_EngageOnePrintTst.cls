@isTest
public with sharing class HDT_WS_EngageOnePrintTst {
    
    //DATA
    private static Boolean isFailure = false;
    private static Boolean isException = false;
    
    //sendFileTest
    
    ///FAILURE
    @isTest
    private static void sendFileTest_failure() {
        
        //SETUP
        isFailure = true;
        String bodyString = '';
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TEST
        HDT_WS_EngageOnePrint.HDT_WRP_ReturnObj result = HDT_WS_EngageOnePrint.sendFile(bodyString);
        
        //ASSERTS
        System.assert(!result.success);
        System.assert(result.message.contains('Test_Message_Failure'));
        
    }
    
    
    ///SUCCESS
    @isTest
    private static void sendFileTest_success() {
        
        //SETUP
        String bodyString = '';
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TEST
        HDT_WS_EngageOnePrint.HDT_WRP_ReturnObj result = HDT_WS_EngageOnePrint.sendFile(bodyString);
        
        //ASSERTS
        System.assert(result.success);
        System.assert(String.isBlank(result.message));
        
    }
    
    
    ///INTENTIONAL EXCEPTION
    @isTest
    private static void sendFileTest_exception() {
        
        //SETUP
        isException = true;
        String bodyString = '';
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TEST
        HDT_WS_EngageOnePrint.HDT_WRP_ReturnObj result = HDT_WS_EngageOnePrint.sendFile(bodyString);
        
        //ASSERTS
        System.assert(!result.success);
        System.assert(result.message.contains('ERROR: line ['));
        
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
    
}
