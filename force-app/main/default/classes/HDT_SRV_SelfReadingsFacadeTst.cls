@isTest
public with sharing class HDT_SRV_SelfReadingsFacadeTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_SelfReadingsFacadeTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static boolean fail_WS_1 = false;
    private static boolean fail_WS_2 = false;
    
    
    
    //TODO: RICORDARSI DI TESTARE LE selfReadings AL COMPLETO.
    
    
    
    //TEST SETUP
    //TODO: POSSIBILE CHE DEBBA ESSERE USATO CASE CON TIPO AD HOC RELATIVO ALLE LETTURE
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
    
    //TODO: IMPLEMENTARE ANCHE CASI CON RESPONSE CODE DIVERSO DA 200 E 201
    
    
    ///CheckAutolettura
    @isTest
    private static void executeTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - executeTest';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case];
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('requestType', 'CheckAutolettura');//TODO: IMPLEMENTARE CASI ALTERNATIVI
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //PHASE ENABLE
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','','','');
        
        //TESTING
        Test.startTest();
        
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(argsMap);
        
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, Phase__c FROM Case];
        
        //ASSERTS
        System.assertEquals('Inviata a SAP', myUpdatedCase.Phase__c);
        
    }
    
    ///InvioLettureForzato
    
    
    
    //WEBSERVICE MOCKS
    
    public class myWebServiceMock implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            //DEBUG
            System.debug('myWebServiceMock - respond');
            HttpResponse response = new HttpResponse();
            
            //CheckAutolettura
            if(request.getEndpoint().equalsIgnoreCase('Callout:SelfReadingsCheck')){
                
                //DEBUG
                System.debug('myWebServiceMock - SelfReadingsCheck');
                
                //PREPARING RESPONSE
                Map<String, Object> data = new Map<String, Object>();
                data.put('message', 'data fuori finestra acquisibile');
                
                Map<String, Object> body = new Map<String, Object>();
                body.put('data', data);
                
                //HTTP RESPONSE
                response.setHeader('Content-Type', 'application/json');
                response.setBody(JSON.serialize(body));
                response.setStatusCode(200);
                response.setStatus('OK');
                
            } else if(request.getEndpoint().equalsIgnoreCase('Callout:SendReadings')){
                
                //DEBUG
                System.debug('myWebServiceMock - SendReadings');
                
                //PREPARING RESPONSE
                Map<String, Object> body = new Map<String, Object>();//EMPTY BODY PER CODE 200 o 201
                
                //HTTP RESPONSE
                response.setHeader('Content-Type', 'application/json');
                response.setBody(JSON.serialize(body));
                response.setStatusCode(200);
                response.setStatus('OK');
                
            }
            
            return response;
        }
    }
    
    
}
