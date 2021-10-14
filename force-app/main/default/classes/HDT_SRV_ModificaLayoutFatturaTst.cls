@isTest
public with sharing class HDT_SRV_ModificaLayoutFatturaTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_ModificaLayoutFatturaTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    //TESTS
    
    //executeTest
    @isTest
    private static void executeTest_ok() {
        
        //DEBUG
        String debugString = 'HDT_SRV_ModificaLayoutFatturaTst - executeTest_ok';
        
        //SETUP
        mySetup();
        
        //SUB-SETUP
        ///CLICK
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        ///AUTORIZZARE CAMBI DI FASE SUL CASE
        Id rt=constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'Bozza', rt, 'HDT_RT_Morosita');
        
        String method_OK = 'ModificaLayoutFattura';//NOTA: in verità è endpoint.
        
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', method_OK);
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myMockForTest());
        
        //TESTING
        Test.startTest();
        HDT_SRV_ModificaLayoutFattura myObjectToTest = new HDT_SRV_ModificaLayoutFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCase = [SELECT Id, Phase__c,TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success);
        System.assertEquals('OK', result.message);
        //@frpanico 20/09/2021 a seguito di modifica classe adeguata anche classe di test
        System.assertEquals('Completata', myCase.TecnicalPhase__c);//TODO: 'Errore Lavorazione SAP'
        
    }
    
    @isTest
    private static void executeTest_null() {
        
        //DEBUG
        String debugString = 'HDT_SRV_ModificaLayoutFatturaTst - executeTest_null';
        
        //SETUP
        mySetup();
        
        //SUB-SETUP
        ///CLICK
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        ///AUTORIZZARE CAMBI DI FASE SUL CASE
        Id rt=constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Errore Lavorazione SAP', 'Bozza', rt, 'HDT_RT_Morosita');
        
        //TESTING
        String method_dataNull = 'ModificaLayoutFattura_null';//NOTA: in verità è endpoint.
        
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', method_dataNull);
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myMockForTest());
        
        //TESTING
        Test.startTest();
        HDT_SRV_ModificaLayoutFattura myObjectToTest = new HDT_SRV_ModificaLayoutFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCase = [SELECT Id, Phase__c,TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success);
        System.assertEquals('OK', result.message);
        //@frpanico 20/09/2021 a seguito di modifica classe adeguata anche classe di test
        System.assertEquals('Errore Lavorazione SAP', myCase.TecnicalPhase__c);//TODO: 'Errore Lavorazione SAP'
        
    }
    
    @isTest
    private static void executeTest_NotOk() {
        
        //DEBUG
        String debugString = 'HDT_SRV_ModificaLayoutFatturaTst - executeTest_NotOk';
        
        //SETUP
        mySetup();
        
        //SUB-SETUP
        ///CLICK
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        ///AUTORIZZARE CAMBI DI FASE SUL CASE
        Id rt=constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Errore Lavorazione SAP', 'Bozza', rt, 'HDT_RT_Morosita');
        
        //TESTING
        String method_notOK = 'ModificaLayoutFattura_notOK';//NOTA: in verità è endpoint.
        
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('method', method_notOK);
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myMockForTest());
        
        //TESTING
        Test.startTest();
        HDT_SRV_ModificaLayoutFattura myObjectToTest = new HDT_SRV_ModificaLayoutFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myCase = [SELECT Id, Phase__c,TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success);
        System.assertEquals('OK', result.message);
        //@frpanico 20/09/2021 a seguito di modifica classe adeguata anche classe di test
        System.assertEquals('Errore Lavorazione SAP', myCase.TecnicalPhase__c);//TODO: 'Errore Lavorazione SAP'
        
    }
    
    
    
    
    //WEBSERVICE MOCK
    public class myMockForTest implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            HttpResponse response = new HttpResponse();
            System.debug('request.getEndpoint: ' + request.getEndpoint());
            
            if('Callout:ModificaLayoutFattura'.equals(request.getEndpoint())){
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data wrpDATA = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data();
                wrpDATA.rds = 'rds';
                wrpDATA.attivita = 'Esito OK da SAP';
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
                bodyResp.status = 'TST_Status';
                bodyResp.correlationId = 'TST_CorrelId';
                bodyResp.timestamp = 'TST_TimeStamp';
                bodyResp.data = wrpDATA;
                
                
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
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data wrpDATA = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data();
                wrpDATA.rds = 'rds';
                wrpDATA.attivita = 'Test';//TARGET
                
                HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
                bodyResp.status = 'TST_Status';
                bodyResp.correlationId = 'TST_CorrelId';
                bodyResp.timestamp = 'TST_TimeStamp';
                bodyResp.data = wrpDATA;
                
                String bodyResponse = JSON.serialize(bodyResp);
                
                response.setHeader('Content-Type', 'application/json');
                response.setBody(bodyResponse);
                response.setStatusCode(200);
                response.setStatus('OK');
                
                return response;
                
            } else {
                System.debug('Invalid Callout Endpoint - Empty HTTP Response.');
                
            }
            
            return response;
        }
        
    }
    
    
}
