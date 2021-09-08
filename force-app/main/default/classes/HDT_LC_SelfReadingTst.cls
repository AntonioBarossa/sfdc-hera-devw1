@isTest
public with sharing class HDT_LC_SelfReadingTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_SelfReadingTst';
    
    //DATA
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    
    //TEST SETUP
    
    //SETUP WITH CASE MOROSITà
    private static void setupMorosita(){
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        
        //VOLTURA ORDER
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        Order myOrder = ordList[0];
        myOrder.recordTypeId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
        myOrder.ProcessType__c = 'Voltura';
        myOrder.Contact__c = contactList[0].Id;
        
        insert ordList;
        
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    
    //TESTS
    
    //insertSelfReading
    @isTest
    private static void insertSelfReadingTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'insertSelfReadingTest';
        System.debug(debugString);
        
        //SETUP
        Reading__c myReading = new Reading__c();
        String myReadingSTR = JSON.serialize(myReading);
        
        //TESTING
        HDT_LC_SelfReading.insertSelfReading(myReadingSTR);
        
        //RETRIEVE DATA
        Reading__c result = [SELECT Id FROM Reading__c];
        
        //ASSERTS
        System.assertNotEquals(null, result);
        
    }
    
    //updateSelfReading
    @isTest
    private static void updateSelfReadingTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateSelfReadingTest';
        System.debug(debugString);
        
        //SETUP
        Reading__c myReading = new Reading__c();
        insert myReading;
        String myReadingSTR = JSON.serialize(myReading);
        
        //TESTING
        HDT_LC_SelfReading.updateSelfReading(myReadingSTR);
        
        //RETRIEVE DATA
        Reading__c result = [SELECT Id FROM Reading__c];
        
        //ASSERTS
        System.assertNotEquals(null, result);
        
    }
    
    
    //getReadingId
    //Gas
    @isTest
    private static void getReadingIdTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getReadingIdTest';
        System.debug(debugString);
        
        //SETUP
        setupMorosita();
        Case myCase = [SELECT Id FROM Case];
        
        Reading__c myReading = new Reading__c();
        myReading.CaseGas__c = myCase.Id;
        insert myReading;
        String myReadingSTR = JSON.serialize(myReading);
        
        //TESTING
        Id result = HDT_LC_SelfReading.getReadingId('Case', myCase.Id, 'Gas');
        
        //ASSERTS
        System.assertNotEquals(null, result);
        System.assertEquals(myReading.Id, result);
        
    }
    
    //updateOrder
    @isTest
    private static void updateOrderTest_true() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateOrderTest_true';
        System.debug(debugString);
        
        //SETUP
        setupMorosita();
        
        Order myOrder = [SELECT Id, Phase__c, RecordTypeId, RecordType.DeveloperName FROM Order];
        
        String serialOrder = JSON.serialize(myOrder);
        String recordId = myOrder.Id;
        Boolean isRetroactive = true;
        Boolean isReading = true;
        Date rcd = Date.today().addDays(-1);
        Boolean completed = true;
        
        System.debug(debugString + ' - myOrder: ' + myOrder);
        
        //PROCESS CLICK
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        //PHASE MANAGER
        String rtId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
        String rtName = utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA;
        
        System.debug(debugString + ' - Record Type: ' + rtId + ' ' + rtName);
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Accettazione Voltura', 'Bozza', rtId, rtName,'A','','','');
        
        //TESTING
        String result = HDT_LC_SelfReading.updateOrder(serialOrder, recordId, isRetroactive, isReading, rcd, completed);
        
        //ASSERTS
        System.assertEquals(null, result);
        
    }
    
    @isTest
    private static void updateOrderTest_false() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateOrderTest_false';
        System.debug(debugString);
        
        //SETUP
        setupMorosita();
        
        Order myOrder = [SELECT Id, Phase__c, RecordTypeId, RecordType.DeveloperName FROM Order];
        
        String serialOrder = JSON.serialize(myOrder);
        String recordId = myOrder.Id;
        Boolean isRetroactive = false;
        Boolean isReading = true;
        Date rcd = Date.today().addDays(-1);
        Boolean completed = false;
        
        System.debug(debugString + ' - myOrder: ' + myOrder);
        
        //PROCESS CLICK
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        //PHASE MANAGER
        String rtId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
        String rtName = utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA;
        
        System.debug(debugString + ' - Record Type: ' + rtId + ' ' + rtName);
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Accettazione Voltura', 'Bozza', rtId, rtName,'A','','','');
        
        //TESTING
        String result = HDT_LC_SelfReading.updateOrder(serialOrder, recordId, isRetroactive, isReading, rcd, completed);
        
        //ASSERTS
        System.assertEquals(null, result);
    }
    
    @isTest
    private static void updateOrderTest_causingExcpts() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateOrderTest_causingExcpts';
        System.debug(debugString);
        
        //SETUP
        setupMorosita();
        
        Order myOrder = [SELECT Id, Phase__c, RecordTypeId, RecordType.DeveloperName FROM Order];
        myOrder.RetroactiveDate__c = Date.today();
        
        String serialOrder = JSON.serialize(myOrder);
        String recordId = myOrder.Id;
        Boolean isRetroactive = true;
        Boolean isReading = false;
        Date rcd = Date.today();
        Boolean completed = false;
        
        System.debug(debugString + ' - myOrder: ' + myOrder);
        
        //PROCESS CLICK
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        //PHASE MANAGER
        String rtId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
        String rtName = utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA;
        
        System.debug(debugString + ' - Record Type: ' + rtId + ' ' + rtName);
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Accettazione Voltura', 'Bozza', rtId, rtName,'A','','','');
        
        //TESTING EXCEPTION 1
        Boolean caught_1 = false;
        try{
            String result = HDT_LC_SelfReading.updateOrder(serialOrder, recordId, isRetroactive, isReading, rcd, completed);

        } catch (Exception e) {
            caught_1 = true;
            
        }
        
        //ASSERTS EXCEPTION 1
        System.assert(caught_1);
        
        
       
        //TESTING EXCEPTION 2
        Boolean caught_2 = false;
        rcd = Date.today().addDays(-1);
        myOrder.SignedDate__c = Date.today().addDays(1);
        serialOrder = JSON.serialize(myOrder);
        
        try{
            String result = HDT_LC_SelfReading.updateOrder(serialOrder, recordId, isRetroactive, isReading, rcd, completed);

        } catch (Exception e) {
            caught_2 = true;
            
        }
        
        //ASSERTS EXCEPTION 2
        System.assert(caught_2);
        
    }
    
    
    //getRecordTypeId
    @isTest
    private static void getRecordTypeIdTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getRecordTypeIdTest';
        System.debug(debugString);
        
        //TESTING
        Id result = HDT_LC_SelfReading.getRecordTypeId('Gas');
        
        //RETRIEVING DATA
        RecordType recType = [SELECT Id FROM RecordType WHERE DeveloperName = 'HDT_RT_LetturaGas' WITH SECURITY_ENFORCED];
        
        //ASSERTS
        System.assertEquals(recType.Id, result);
        
    }
    
    
    //checkLastReadings
    @isTest
    private static void checkLastReadingsTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'checkLastReadingsTest';
        System.debug(debugString);
        
        //SETUP
        setupMorosita();
        
        //SERVICE POINT
        ServicePoint__c servPoint = new ServicePoint__c();
        insert servPoint;
        
        //TESTING ERROR_NO_ASSET_NUMBER
        String result = HDT_LC_SelfReading.checkLastReadings(servPoint.Id);
        
        //ASSERTS
        System.assertEquals('ERROR_NO_ASSET_NUMBER', result);
        
        
        
        //TESTING REGULAR
        
        
        
        //JSON
        /*
        {
            "requestType": "VerificaUltimaLettura",
            "objects": [
                {
                    "objectLabel": "ServicePoint",
                    "objectName": "ServicePoint__c",
                    "fields": [
                        {
                            "fieldType": "",
                            "apiName": "ServicePointCode__c",
                            "label": "herPodPdr"
                        },
                        {
                            "fieldType": "",
                            "apiName": "SAPImplantCode__c",
                            "label": "assetNumber"
                        }
                    ],
                    "childObjects":[]
                }
            ]
        }
        */
        String myJSON = '{"requestType": "VerificaUltimaLettura","objects": [{"objectLabel": "ServicePoint","objectName": "ServicePoint__c","fields": [{"fieldType": "","apiName": "ServicePointCode__c","label": "herPodPdr"},{"fieldType": "","apiName": "SAPImplantCode__c","label": "assetNumber"}],"childObjects":[]}]}';
        
        
        servPoint.SAPImplantCode__c = 'Test_Implant_Code';
        update servPoint;
        
        
        //WEBSERVICE MOCKS
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        
        
        
        //HDT_WRP_SapFields
        HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapFields childField_1 = new HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapFields();
        
        //HDT_WRP_SapChildObjects
        HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapChildObjects childObj_1 = new HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapChildObjects();
        childObj_1.fields = new List<HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapFields> {childField_1};
        
        //HDT_WRP_SapParentObjects
        HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapParentObjects parentObj_1 = new HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapParentObjects();
        parentObj_1.childObjects = new List<HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapParentObjects> {childObj_1};
        
        //HDT_WRP_SapRequest
        HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapRequest mySAPRequest = new HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapRequest();
        mySAPRequest.requestType = 'VerificaUltimaLettura';                
        mySAPRequest.objects = new List<HDT_WRP_GenericSapIntegrationAdapter.HDT_WRP_SapParentObjects> {parentObj_1};
        
        
        //METADATA TYPE HDT_SapWsConfiguration__mdt
        HDT_SapWsConfiguration__mdt myMetaData = new HDT_SapWsConfiguration__mdt();
        myMetaData.DeveloperName = 'VerificaUltimaLettura';
        
        myMetaData.JSON__c = myJSON;//JSON.serialize(mySAPRequest);
        
        myMetaData.NamedCredential__c = 'Callout:CheckLastReading';
        
        
        //TESTING
        Test.startTest();
            
            result = HDT_LC_SelfReading.checkLastReadings(servPoint.Id);
            
            
        Test.stopTest();
        
        //ASSERTS
        
        
    }
    
}
