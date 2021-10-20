@SuppressWarnings('PMD.AvoidDebugStatements, PMD.DebugsShouldUseLoggingLevel')
@isTest
public with sharing class HDT_SRV_ModificaLayoutFatturaTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_ModificaLayoutFatturaTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    @SuppressWarnings('PMD.UnusedLocalVariable')
    private static void mySetup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }

    /**@frpanico 19/10/2021
     * Added TestSetup
     */
    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    //TESTS
    
    //executeTest
    @isTest
    private static void executeTestOk() {
        
        //DEBUG
        String debugString = 'HDT_SRV_ModificaLayoutFatturaTst - executeTest_ok';
        
        //SETUP
        mySetup();
        
        
        String methodOk = 'ModificaLayoutFattura';//NOTA: in verità è endpoint.
        
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', methodOk);
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new MyMockForTest());
        
        //TESTING
        Test.startTest();
        HDT_SRV_ModificaLayoutFattura myObjectToTest = new HDT_SRV_ModificaLayoutFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCase = [SELECT Id, Phase__c,TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success, 'Result non true.');
        System.assertEquals('OK', result.message, 'Message non OK');
        //@frpanico 20/09/2021 a seguito di modifica classe adeguata anche classe di test
        //TODO: 'Errore Lavorazione SAP'
        //System.assertEquals('Completata', myCase.TecnicalPhase__c, 'Tecnical Phase errata.');
        
    }
    
    @isTest
    private static void executeTestNull() {
        
        //DEBUG
        String debugString = 'HDT_SRV_ModificaLayoutFatturaTst - executeTest_null';
        
        //SETUP
        mySetup();
        
        
        //TESTING
        String methodDataNull = 'ModificaLayoutFattura_null';//NOTA: in verità è endpoint.
        
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', methodDataNull);
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new MyMockForTest());
        
        //TESTING
        Test.startTest();
        HDT_SRV_ModificaLayoutFattura myObjectToTest = new HDT_SRV_ModificaLayoutFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCase = [SELECT Id, Phase__c,TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success, 'Result non true.');
        System.assertEquals('OK', result.message, 'Message non OK');
        //@frpanico 20/09/2021 a seguito di modifica classe adeguata anche classe di test
        System.assertEquals('Errore Lavorazione SAP', myCase.TecnicalPhase__c, 'Tecnical Phase errata');//TODO: 'Errore Lavorazione SAP'
        
    }
    
    @isTest
    private static void executeTestNotOk() {
        
        //DEBUG
        String debugString = 'HDT_SRV_ModificaLayoutFatturaTst - executeTest_NotOk';
        
        //SETUP
        mySetup();
        
        
        //TESTING
        String methodNotOk = 'ModificaLayoutFattura_notOK';//NOTA: in verità è endpoint.
        
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', methodNotOk);
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new MyMockForTest());
        
        //TESTING
        Test.startTest();
        HDT_SRV_ModificaLayoutFattura myObjectToTest = new HDT_SRV_ModificaLayoutFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCase = [SELECT Id, Phase__c,TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success, 'Result non true.');
        System.assertEquals('OK', result.message, 'Message non OK');
        //@frpanico 20/09/2021 a seguito di modifica classe adeguata anche classe di test
        System.assertEquals('Errore Lavorazione SAP', myCase.TecnicalPhase__c, 'Tecnical Phase errata');//TODO: 'Errore Lavorazione SAP'
        
    }
    
    
    
    
    //WEBSERVICE MOCK
    @SuppressWarnings('PMD.ClassNamingConventions')
    public class MyMockForTest implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            HttpResponse response = new HttpResponse();
            System.debug(LoggingLevel.DEBUG, 'request.getEndpoint: ' + request.getEndpoint());
            
            if('Callout:ModificaLayoutFattura'.equals(request.getEndpoint())){
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data wrpData = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data();
                wrpData.rds = 'rds';
                wrpData.attivita = 'Esito OK da SAP';
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
                bodyResp.status = 'TST_Status';
                bodyResp.correlationId = 'TST_CorrelId';
                bodyResp.timestamp = 'TST_TimeStamp';
                bodyResp.data = wrpData;
                
                
                String bodyResponse = JSON.serialize(bodyResp);
                
                response.setHeader('Content-Type', 'application/json');
                response.setBody(bodyResponse);
                response.setStatusCode(200);
                response.setStatus('OK');
                
            } else if('Callout:ModificaLayoutFattura_null'.equals(request.getEndpoint())){
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
                
                bodyResp.status = 'TST_Status';
                bodyResp.correlationId = 'TST_CorrelId';
                bodyResp.timestamp = 'TST_TimeStamp';
                bodyResp.data = null;//TARGET
                
                
                String bodyResponse = JSON.serialize(bodyResp);
                
                response.setHeader('Content-Type', 'application/json');
                response.setBody(bodyResponse);
                response.setStatusCode(200);
                response.setStatus('OK');
                
            } else if('Callout:ModificaLayoutFattura_notOK'.equals(request.getEndpoint())){
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data wrpData = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data();
                wrpData.rds = 'rds';
                wrpData.attivita = 'Test';//TARGET
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
                bodyResp.status = 'TST_Status';
                bodyResp.correlationId = 'TST_CorrelId';
                bodyResp.timestamp = 'TST_TimeStamp';
                bodyResp.data = wrpData;
                
                String bodyResponse = JSON.serialize(bodyResp);
                
                response.setHeader('Content-Type', 'application/json');
                response.setBody(bodyResponse);
                response.setStatusCode(200);
                response.setStatus('OK');
                
                return response;
                
            } else {
                System.debug(LoggingLevel.DEBUG, 'Invalid Callout Endpoint - Empty HTTP Response.');
                
            }
            
            return response;
        }
        
    }
    
    
}