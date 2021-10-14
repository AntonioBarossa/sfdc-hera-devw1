@isTest
public with sharing class HDT_LC_CanaleIVRNoShareTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_CanaleIVRNoShareTst';
    
    
    //TEST SETUP
    
    
    
    //TESTS
    
    //getOrderByUsernamePassword
    @isTest
    private static void getOrderByUsernamePasswordTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getOrderByUsernamePasswordTest';
        System.debug(debugString);
        
        //SETUP
        String username = '';
        String password = '';
        
        //TESTING
        HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
        List<Order> result = myChannel.getOrderByUsernamePassword(username, password);
        
        //ASSERTS
        System.assertEquals(0, result.size(),'value of parameter is matching');
        
    }
    
    //getActivityByOrder
    @isTest
    private static void getActivityByOrderTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getActivityByOrderTest';
        System.debug(debugString);
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        DocumentalActivity__c myDoc = HDT_UTL_DataFactoryTst.createDocumentalActivity(1, ordList[0].Id, caseList[0].Id)[0];
        
        //TESTING
        HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
        DocumentalActivity__c result = myChannel.getActivityByOrder(ordList[0].Id);
        
        //ASSERTS
        System.assertNotEquals(null, result,'value of parameter is not matching');
        System.assertEquals(myDoc.Id, result.Id,'value of parameter is matching');
        
    }
    
    //getPlico
    @isTest
    private static void getPlicoTest_DocumentalActivity() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getPlicoTest_DocumentalActivity';
        System.debug(debugString);
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        DocumentalActivity__c myDoc = HDT_UTL_DataFactoryTst.createDocumentalActivity(1, ordList[0].Id, caseList[0].Id)[0];
        
        //WEBSERVICE MOCK
        //Mock HTTP
        //???
        
        //Mock HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse via HDT_WS_PostSalesTstMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        
        //TESTING - DocumentalActivity__c
        Test.startTest();
            HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
            Map<String,String> result = myChannel.getPlico(myDoc.Id);
        Test.stopTest();
        
        //ASSERTS
        System.assertNotEquals(null, result,'value of parameter is not matching');
        System.assertEquals('OK', result.get('outcome'),'value of parameter is matching');
        
    }
    
    @isTest
    private static void getPlicoTest_DocumentSendTracking() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getPlicoTest_DocumentSendTracking';
        System.debug(debugString);
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        DocumentSendTracking__c myDoc = HDT_UTL_DataFactoryTst.createDocumentSendTracking(1, ordList[0].Id, caseList[0].Id)[0];
        
        //WEBSERVICE MOCK
        
        //Mock HDT_WRP_DocumentalResponse.HDT_WRP_PostelResponse via HDT_WS_PostSalesTstMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        
        //TESTING - DocumentSendTracking__c
        Test.startTest();
            HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
            Map<String,String> result = myChannel.getPlico(myDoc.Id);
        Test.stopTest();
        
        //ASSERTS
        System.assertNotEquals(null, result,'value of parameter is not matching');
        System.assertEquals('OK', result.get('outcome'),'value of parameter is matching');
        
        
        //TESTING - Null
        
        
        //ASSERTS
        
        
    }
    
    @isTest
    private static void getPlicoTest_Null() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getPlicoTest_Null';
        System.debug(debugString);
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        
        //TESTING - Wrong Id
        HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
        Map<String,String> result_wrong = myChannel.getPlico(accList[0].Id);
        Map<String,String> result_null = myChannel.getPlico(null);
        
        //ASSERTS
        System.assertNotEquals(null, result_wrong,'value of parameter is not matching');
        System.assertEquals('KO', result_wrong.get('outcome'),'value of parameter is matching');
        System.assertEquals('Errore interno nel recupero del documento archiviato.', result_wrong.get('errorMessage'),'value of parameter is matching');
        
    }
    
}