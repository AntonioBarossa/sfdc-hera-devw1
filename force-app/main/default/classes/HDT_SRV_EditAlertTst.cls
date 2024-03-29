@isTest
public with sharing class HDT_SRV_EditAlertTst {
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_EditAlertTst';
    private static final HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static Boolean isOk = true;
    
    
    //TEST SETUP
    @TestSetup
    static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        String rtName =  constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constants.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Errore Lavorazione SAP', 'Bozza', rtId, rtName,'A','','','');
    }

    @isTest
    private static void executeTest_OK() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_OK';
        System.debug(debugString);
        
        Case myCase = [SELECT Id FROM Case];
        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('sender', myCase);
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock(200,myCase.Id));
        Test.startTest();
        HDT_SRV_EditAlert myObjectToTest = new HDT_SRV_EditAlert();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        System.assert(result.success);
        System.assert('OK'.equalsIgnoreCase(result.message));
    }

    @isTest
    private static void executeTest_Error() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_Error';
        System.debug(debugString);
        
        //SETUP
        isOk = false;
        Case myCase = [SELECT Id FROM Case];
        Map<String, Object> argsMap = new Map<String, Object>();
        argsMap.put('sender', myCase);
        Test.setMock(HttpCalloutMock.class, new myWebServiceMock(201,myCase.Id));
        Test.startTest();
        HDT_SRV_EditAlert myObjectToTest = new HDT_SRV_EditAlert();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObjectToTest.execute(argsMap);
        Test.stopTest();
        System.assert(result.success);
        System.assert('OK'.equalsIgnoreCase(result.message));
    }

    @isTest
    private static void updateFutureTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - updateFutureTest';
        System.debug(debugString);
        
        //TESTING
        Case myCase = [SELECT Id FROM Case];
        Test.startTest();
        HDT_SRV_EditAlert.updateFuture(JSON.serialize(myCase));
        Test.stopTest();
        Case updatedCase=[SELECT Id FROM Case];
        System.assertEquals(myCase,updatedCase, 'case updated correctly');
    }

    //WEBSERVICE MOCKS
    public class myWebServiceMock implements HTTPCalloutMock{
        Integer statusCode;
        Id recordId;
        public myWebServiceMock(Integer statusCode, Id recordId){
            this.statusCode=statusCode;
            this.recordId=recordId;
        }
        public HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(new Map<String,Object>{
                    'note'=>statusCode==200 ? 'OK':'KO',
                    'recordId'=>recordId,
                    'responseCode'=>statusCode
            }));
            response.setStatusCode(statusCode);
            response.setStatus(statusCode==200 ? 'OK':'KO');
            return response;
        }
    }
    
}