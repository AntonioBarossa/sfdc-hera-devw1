@isTest
public with sharing class HDT_SRV_SelfReadingsFacadeTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_SelfReadingsFacadeTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static Boolean processError1 = false;
    private static Boolean processError2 = false;
    private static String myCommodity = 'Gas';
    private static Boolean isMeterCorrector = true;
    private static Boolean isCaseWithOrigin = false;
    
    
    
    //TEST SETUP
    private static void mySetup(){
        
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        
        ServicePoint__c servPoint;
        servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
        servPoint.CommoditySector__c = myCommodity;
        insert servPoint;
        
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        
        //CASE
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactList[0].Id, servPoint.Id, contractList[0].id, ordList[0].id);
        if(isCaseWithOrigin){
            Case myCase = caseList[0];
            myCase.Origin = 'Sportello';
        }
        insert caseList;

        List<Case> caseList2 = HDT_UTL_DataFactoryTst.createCase(1, false, acc[0].Id, contactList[0].Id, servPoint.Id, contractList[0].id, ordList[0].id);
        caseList2.get(0).Type = 'Rettifica Consumi';
        caseList2.get(0).Subprocess__c = 'Errore Stima Consumi';
        caseList2.get(0).RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_FatturazioneConsumi').getRecordTypeId();
        insert caseList2;

        List<Case> caseList3 = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactList[0].Id, servPoint.Id, contractList[0].id, ordList[0].id);
        caseList3.get(0).ParentId = caseList2.get(0).Id;
        caseList3.get(0).Type = 'Autolettura da cliente';
        insert caseList3;
        
        //READING
        if(isMeterCorrector){
            List<Reading__c> readings = HDT_UTL_DataFactoryTst.createReadingMeterCorrector(1, true, caseList[0].Id);
            List<Reading__c> readingsList2 = HDT_UTL_DataFactoryTst.createReadingMeterCorrector(1, true, caseList2[0].Id);
        } else {
            List<Reading__c> readings = HDT_UTL_DataFactoryTst.createReading(1, true, caseList[0].Id);
        }
    }

    /**@Francesco Vitiello 20/10/2021
     * Added TestSetup to PClick Settings
     */
    @TestSetup
    static void setup(){        

        HDT_UTL_DataFactoryTst.pClickCasePhase();

        //PHASE ENABLE
        String rtName = constants.CASE_RECORDTYPE_DEVELOPERNAME_AUTOLETTURA;
        String rtId = constants.CASE_RECORDTYPEID_AUTOLETTURA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Check preliminari OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','','','');
    }
    
    
    //TESTS
    
    //execute
    ///CheckAutolettura - GAS
    @isTest
    private static void executeTestCheckAutolettura() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - executeTestCheckAutolettura';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('requestType', 'CheckAutolettura');
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        
        //TESTING
        Test.startTest();
        
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(argsMap);
        
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, Phase__c FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        //ASSERTS
        System.assertEquals('Bozza', myUpdatedCase.Phase__c, '');
        
    }
    
    
    ///CheckAutolettura - NON GAS
    @isTest
    private static void executeTestCheckAutoletturaNg() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - executeTestCheckAutoletturaNg';
		System.debug(debugString);
        
        //SETUP
        myCommodity = 'Teleriscaldamento';
        isMeterCorrector = false;
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('requestType', 'CheckAutolettura');
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TESTING
        Test.startTest();
        
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(argsMap);
        
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, Phase__c FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        //ASSERTS
        System.assertEquals('Check preliminari OK', myUpdatedCase.Phase__c, '');
    }
    
    
    
    
    
    
    
    ///InvioLettureForzato - GAS
    @isTest
    private static void executeTestInvioLettureForzatoNg() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - executeTestInvioLettureForzatoNg';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('requestType', 'InvioLettureForzato');//TODO: IMPLEMENTARE CASI ALTERNATIVI
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TESTING
        Test.startTest();
        
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(argsMap);
        
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, Phase__c FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        //ASSERTS
        System.assertEquals('Inviata a SAP', myUpdatedCase.Phase__c, '');
        
    }
    
    
    ///InvioLettureForzato - NON GAS
    @isTest
    private static void executeTestInvioLettureForzato() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - executeTestInvioLettureForzato';
		System.debug(debugString);
        
        //SETUP
        myCommodity = 'Teleriscaldamento';
        isMeterCorrector = false;
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('requestType', 'InvioLettureForzato');//TODO: IMPLEMENTARE CASI ALTERNATIVI
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TESTING
        Test.startTest();
        
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(argsMap);
        
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, Phase__c FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        //ASSERTS
        System.assertEquals('Inviata a SAP', myUpdatedCase.Phase__c, 'Errore');
        
    }
    
    
    
    
    ///Eccezione intenzionale - Causata con submitRequest
    @isTest
    private static void executeTestException() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - executeTestException';
		System.debug(debugString);
        
        //SETUP
        processError1 = true;
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('requestType', 'CheckAutolettura');
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TESTING
        Boolean caught = false;
        
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(argsMap);
        
        //ASSERTS
        System.assert(!result.success, '');
        System.assertEquals('KO', result.message, '');
        
    }
    
    
    //generateJson - Null
    @isTest
    private static void generateJsonTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - generateJsonTest';
		System.debug(debugString);
        
        //SETUP
        HDT_WRP_GenericSapIntegration inputParams = new HDT_WRP_GenericSapIntegration();
        inputParams.requestType = 'Fake';
        
        //TESTING
        HDT_WRP_GenericSapIntegration result = HDT_SRV_SelfReadings.generateJson(inputParams);
        
        //ASSERTS
        System.assertEquals(null, result, '');
        
    }
    
    //generateJsonCheckAutolettura
    @isTest
    private static void generateJsonCheckAutoletturaTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - generateJsonCheckAutoletturaTest';
		System.debug(debugString);
        
        //SETUP
        HDT_WRP_GenericSapIntegration inputParams;
        
        //TESTING
        HDT_WRP_GenericSapIntegration result = HDT_SRV_SelfReadings.generateJsonCheckAutolettura(inputParams);
        
        //ASSERTS
        System.assertEquals(null, result, '');
        
        
        //TESTING - NO CASES
        inputParams = new HDT_WRP_GenericSapIntegration();
        inputParams.recordId = '';
        result = HDT_SRV_SelfReadings.generateJsonCheckAutolettura(inputParams);
        
        //ASSERTS
        System.assertEquals(null, result, '');
        
    }
    
    
    //generateJsonInvioLetture
    @isTest
    private static void generateJsonInvioLettureTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - generateJsonInvioLettureTest';
		System.debug(debugString);
        
        //SETUP
        HDT_WRP_GenericSapIntegration inputParams;
        
        //TESTING
        HDT_WRP_GenericSapIntegration result = HDT_SRV_SelfReadings.generateJsonInvioLetture(inputParams);
        
        //ASSERTS
        System.assertEquals(null, result, '');
        
        
        //TESTING - NO CASES
        inputParams = new HDT_WRP_GenericSapIntegration();
        inputParams.recordId = '';
        result = HDT_SRV_SelfReadings.generateJsonInvioLetture(inputParams);
        
        //ASSERTS
        System.assertEquals(null, result, '');
        
    }
    
    
    //handleResponse
    @isTest
    private static void handleResponseTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - handleResponseTest';
		System.debug(debugString);
        
        //SETUP
        HDT_WRP_GenericSapIntegration sapIntegration = new HDT_WRP_GenericSapIntegration();
        sapIntegration.requestType = '';
        
        //TESTING
        HDT_SRV_SelfReadings.HDT_WRP_SelfReadingResponse result = HDT_SRV_SelfReadings.handleResponse(sapIntegration, '');
        
        //ASSERTS
        System.assertEquals(null, result, '');
        
    }
    
    
    
    
    //NB: I SEGUENTI SONO COMUNQUE TEST DI EXECUTE DELLA FACADE
    
    //handleResponseCheckAutolettura - RESPONSE CODE NOT 200 OR 201
    @isTest
    private static void handleResponseCheckAutoletturaNot200() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - handleResponseCheckAutoletturaNot200';
		System.debug(debugString);
        
        //SETUP
        processError2 = true;
        isCaseWithOrigin = true;
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('requestType', 'CheckAutolettura');
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        //TESTING
        Test.startTest();
        
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(argsMap);
        
        Test.stopTest();
        
        //RETRIEVING DATA
        Case myUpdatedCase = [SELECT Id, TecnicalPhase__c FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        //ASSERTS
        System.assertEquals('Esito KO da SAP', myUpdatedCase.TecnicalPhase__c, '');
        
    }
    
    
    
    //NB: metodo in questione si appoggia a Job HDT_QBL_SelfReadingsCallouts
    @isTest
    private static void handleInvioLettureForzatoTest(){
        
		//DEBUG
		String debugString = TEST_NAME + ' - handleInvioLettureForzatoTest';
		System.debug(debugString);
        
        //SETUP
        processError1 = true;
        isMeterCorrector = false;
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case WHERE Type <> 'Rettifica Consumi' AND Type <> 'Autolettura da cliente'];
        
        //WEBSERVICE MOCKS
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock());
        
        Test.startTest();
        HDT_SRV_SelfReadings.handleInvioLettureForzato(myCase);
        Test.stopTest();
        
        //
        
    }

    @isTest
    private static void cloneReadingFromParentCaseTest(){
        
		//DEBUG
		String debugString = TEST_NAME + ' - cloneReadingFromParentCaseTest';
		System.debug(LoggingLevel.DEBUG, debugString);
        
        //SETUP
        isMeterCorrector = true;
        mySetup();

        Case myParentCase = [SELECT Id FROM Case WHERE Type = 'Rettifica Consumi' AND Subprocess__c = 'Errore Stima Consumi'];
        Case myChildCase = [SELECT Id, CommodityFormula__c FROM Case WHERE Type = 'Autolettura da cliente'];

        List<HDT_SRV_SelfReadings.HDT_UTL_FlowFatturazioneInputs> inputs = new List<HDT_SRV_SelfReadings.HDT_UTL_FlowFatturazioneInputs>();
        HDT_SRV_SelfReadings.HDT_UTL_FlowFatturazioneInputs input = new HDT_SRV_SelfReadings.HDT_UTL_FlowFatturazioneInputs();
        input.parentCase = myParentCase;
        input.childCase = myChildCase;
        inputs.add(input);
        

        //TESTING
        Test.startTest();
        HDT_SRV_SelfReadings.cloneReadingFromParentCase(inputs);
        Test.stopTest();
        
        Reading__c letturaChild = [SELECT Id FROM Reading__c WHERE CaseGas__c =: myChildCase.Id];
        System.assertNotEquals(null, letturaChild, 'Si è verificato un errore in fase di clonazione della lettura');
        
    }
    
    
    
    
    
    
    //WEBSERVICE MOCKS
    
    public class myWebServiceMock implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            
            //DEBUG
            System.debug('myWebServiceMock - respond');
            HttpResponse response = new HttpResponse();
            
            if(processError1){
                throw new AuraHandledException('Fake Exception for Tests - Exception 1');
            }
            
            //CheckAutolettura
            if(request.getEndpoint().equalsIgnoreCase('Callout:SelfReadingsCheck')){
                
                //DEBUG
                System.debug('myWebServiceMock - SelfReadingsCheck');
                
                if(processError2){
                    System.debug('myWebServiceMock - Introduzione errore manuale');
                    //PREPARING RESPONSE
                    Map<String, Object> myResponseMap = new Map<String, Object>();
                    String myError = 'data fuori finestra (non acquisibile) - registri incompleti';
                    myResponseMap.put('message', myError);
                    
                    List<Object> errorDetails = new List<Object>{myResponseMap};
                    
                    Map<String, Object> body = new Map<String, Object>();
                    body.put('errorDetails', errorDetails);
                    
                    //HTTP RESPONSE
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody(JSON.serialize(body));
                    response.setStatusCode(400);
                    response.setStatus('OK');
                    
                } else {
                    System.debug('myWebServiceMock - Processo normale');
                    //PREPARING RESPONSE
                    Map<String, Object> data = new Map<String, Object>();
                    data.put('message', 'data fuori finestra acquisibile');
                    data.put('outcome', 'OK');
                    
                    Map<String, Object> body = new Map<String, Object>();
                    body.put('data', data);
                    
                    //HTTP RESPONSE
                    response.setHeader('Content-Type', 'application/json');
                    response.setBody(JSON.serialize(body));
                    response.setStatusCode(200);
                    response.setStatus('OK');
                    
                }
                
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
