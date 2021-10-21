@isTest
public with sharing class HDT_LC_DocusignQrCodeTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_DocusignQrCodeTst';
    
    
    //TEST SETUP
    @TestSetup
    private static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    
    //TESTS
    //getDocusignUrl
    @isTest
    private static void getDocusignUrlTest_Case(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getDocusignUrlTest_Case';
        System.debug(debugString);
        
        //SETUP
        Case myCase = [SELECT Id, DocusignURL__c,SendMode__c,SignMode__c,Email__c,PhoneNumber__c FROM Case];
        
        //TESTING
        String result = HDT_LC_DocusignQrCode.getObject(myCase.Id, 'Case');
        
        //ASSERTS
        System.assertEquals(JSON.serialize(myCase), result, 'value of parameter is matching');
        
    }
    
    //getDocusignUrlTest_Else
    @isTest
    private static void getDocusignUrlTest_Else(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getDocusignUrlTest_Else';
        System.debug(debugString);
        
        //SETUP
        Order myOrder = [SELECT Id, DocusignURL__c ,DocSendingMethod__c,SignatureMethod__c,ShippingMail__c,PhoneNumber__c FROM Order];
        
        //TESTING
        String result = HDT_LC_DocusignQrCode.getObject(myOrder.Id, 'Order');
        
        //ASSERTS
        System.assertEquals(JSON.serialize(myOrder), result, 'value of parameter is matching');
        
    }
    
    @isTest
    private static void getDocusignUrlTest_Empty(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getDocusignUrlTest_Empty';
        System.debug(debugString);
        
        //SETUP
        ServicePoint__c myServPoint = [SELECT Id FROM ServicePoint__c];
        
        //TESTING
        String result = HDT_LC_DocusignQrCode.getObject(myServPoint.Id, 'Test');
        
        //ASSERTS
        System.assertEquals(null, result, 'value of parameter is matching');
        
    }
    
}