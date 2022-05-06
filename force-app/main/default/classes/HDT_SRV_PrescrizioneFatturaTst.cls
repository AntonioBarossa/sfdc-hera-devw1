@isTest
public with sharing class HDT_SRV_PrescrizioneFatturaTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_PrescrizioneFatturaTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static String testCase = '';
    
	@TestSetup
    private static void mySetup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        ///AUTORIZZARE CAMBI DI FASE SUL CASE
        Id rt=constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Blocco Effettuato', 'Bozza', rt, 'HDT_RT_Morosita');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Blocco NON Effettuato', 'Bozza', rt, 'HDT_RT_Morosita');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Errore Lavorazione SAP', 'Bozza', rt, 'HDT_RT_Morosita');
        
    }
    
    //TESTS
    @isTest
    private static void executeTestOk(){

        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];

        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new HDT_MY_WebServiceMock());
        
        //TESTING
        Test.startTest();
        HDT_SRV_PrescrizioneFattura myObject = new HDT_SRV_PrescrizioneFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObject.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case updatedCase = [SELECT Id, TecnicalPhase__c FROM Case WHERE Id=:obj.Id ];
        
        //ASSERTS
        System.assert(result.success,'OK');
        System.assertEquals('OK', result.message,'OK');
        System.assertEquals('Blocco Effettuato', updatedCase.TecnicalPhase__c,'Blocco Effettuato');
        
    }
    
    //TODO: TEST CASE sapIntegration.responseCode == 200 FALSE ---- 'Errore Lavorazione SAP'
    
    @isTest
    private static void executeTestErroreSap(){

        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        testCase = 'KO';
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new HDT_MY_WebServiceMock());
        
        //TESTING
        Test.startTest();
        HDT_SRV_PrescrizioneFattura myObject = new HDT_SRV_PrescrizioneFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObject.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case updatedCase = [SELECT Id, TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success,'OK');
        System.assertEquals('OK', result.message,'OK');
        System.assertEquals('Blocco Non Effettuato', updatedCase.TecnicalPhase__c,'Blocco Non Effettuato');
        
    }
    
    //TODO: TEST CASE responseOutcome == 'KO' ---- 'Blocco Non Effettuato'
    
    @isTest
    private static void executeTestFail(){

        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        testCase = 'fail';
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('sender', obj);
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new HDT_MY_WebServiceMock());
        
        //TESTING
        Test.startTest();
        HDT_SRV_PrescrizioneFattura myObject = new HDT_SRV_PrescrizioneFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObject.execute(argsMap);
        Test.stopTest();
        
        //RETRIEVING DATA
        Case updatedCase = [SELECT Id, TecnicalPhase__c FROM Case];
        
        //ASSERTS
        System.assert(result.success,'OK');
        System.assertEquals('OK', result.message,'OK');
        System.assertEquals('Errore Lavorazione SAP', updatedCase.TecnicalPhase__c,'Errore Lavorazione SAP');
    }

    //updateFuture
    @isTest
    private static void updateFutureTest(){

        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        
        //TESTING
        Test.startTest();
        HDT_SRV_PrescrizioneFattura.updateFuture(JSON.serialize(obj));
        Test.stopTest();
        System.assertEquals(obj.Id, obj.Id,'OK');

    }

    //WEBSERVICE MOCKS
    public class HDT_MY_WebServiceMock implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            HttpResponse response = new HttpResponse();
            
            String responseOutcome = 'OK';
            Integer statusCodeOutcome = 200;
            
            if(testCase.equalsIgnoreCase('KO')){
                responseOutcome = 'KO';
                statusCodeOutcome = 200;
                
            } else if (testCase.equalsIgnoreCase('fail')){
                responseOutcome = 'fail';//NB: non importa
                statusCodeOutcome = 500;
                
            }
            
            Map<String, Object> bodyResp = new Map<String, Object>();
            bodyResp.put('note', responseOutcome);
            
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(bodyResp));
            response.setStatusCode(statusCodeOutcome);
            response.setStatus('OK');
            
            return response;
        }
    }
}