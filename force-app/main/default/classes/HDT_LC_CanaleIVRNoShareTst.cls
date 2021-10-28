/**
* @author Andrea Buzzi ()
* @date 02/09/21
* @description HDT_LC_CanaleIVRNoShare test class
* @history LName – dd/mm/yy – description
*/

@isTest
public with sharing class HDT_LC_CanaleIVRNoShareTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_CanaleIVRNoShareTst';
    
    
    //TEST SETUP
    @TestSetup
    static void setup(){
        
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, accounts[0].Id, 'Bozza');
        orders[0].Username__c = 'testUsername';
        orders[0].Password__c = '0123456789';

        insert orders;

        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
        HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orders[0].id);

    }
    
    
    //TESTS
    
    //getOrderByUsernamePassword
    @isTest
    private static void getOrderByUsernamePasswordTest() {
                
        //TESTING
        HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
        List<Order> result = myChannel.getOrderByUsernamePassword('testUsername', '0123456789');
        
        //ASSERTS
        System.assertEquals(1, result.size(), 'The Order was not extracted correctly');
        
    }
    
    //getActivityByOrder
    @isTest
    private static void getActivityByOrderTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getActivityByOrderTest';
        System.debug(debugString);
        
        //SETUP
        List<Order> ordList = [SELECT Id FROM Order];
        List<Case> caseList = [SELECT Id FROM Case];
        
        DocumentalActivity__c myDoc = HDT_UTL_DataFactoryTst.createDocumentalActivity(1, ordList[0].Id, caseList[0].Id)[0];
        
        //TESTING
        HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
        DocumentalActivity__c result = myChannel.getActivityByOrder(ordList[0].Id);
        
        //ASSERTS
        System.assertNotEquals(null, result, 'The Documnental Activity record was not found');
        System.assertEquals(myDoc.Id, result.Id, 'The incorrect Documental Activity was extracted');
        
    }
    
    //getPlico
    @isTest
    private static void getPlicoTestDocumentalActivity() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getPlicoTest_DocumentalActivity';
        System.debug(debugString);
        
        //SETUP
        List<Order> ordList = [SELECT Id FROM Order];
        List<Case> caseList = [SELECT Id FROM Case];
        
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
        System.assertNotEquals(null, result, 'The method didn\'t return the correct result');
        System.assertEquals('OK', result.get('outcome'), 'The outcom of the method was incorrect');
        
    }
    
    @isTest
    private static void getPlicoTestDocumentSendTracking() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getPlicoTest_DocumentSendTracking';
        System.debug(debugString);
        
        //SETUP
        List<Order> ordList = [SELECT Id FROM Order];
        List<Case> caseList = [SELECT Id FROM Case];
        
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
        System.assertNotEquals(null, result, 'The method didn\'t return the correct result');
        System.assertEquals('OK', result.get('outcome'), 'The outcom of the method was incorrect');
        
        
        //TESTING - Null
        
        
        //ASSERTS
        
        
    }
    
    @isTest
    private static void getPlicoTestNull() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getPlicoTest_Null';
        System.debug(debugString);
        
        //SETUP
        List<Account> accList = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'];
        
        //WEBSERVICE MOCK
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        
        //TESTING - Wrong Id
        HDT_LC_CanaleIVRNoShare myChannel = new HDT_LC_CanaleIVRNoShare();
        Map<String,String> resultWrong = myChannel.getPlico(accList[0].Id);

        // TEST NULL recordId
        myChannel.getPlico(null);
        
        //ASSERTS
        System.assertNotEquals(null, resultWrong, 'The outcom of the method was incorrect');
        System.assertEquals('KO', resultWrong.get('outcome'), 'The outcom of the method was incorrect');
        System.assertEquals('Errore interno nel recupero del documento archiviato.', resultWrong.get('errorMessage'), 'The returned error message was not the expected one');
        
    }
    
}
