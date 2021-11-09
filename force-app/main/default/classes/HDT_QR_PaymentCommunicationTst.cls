@isTest
public with sharing class HDT_QR_PaymentCommunicationTst {
    
    //DEBUG
    
    
    //DATA
    
    
    //TEST SETUP
    public static void mySetup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id,billingProfileList[0].ContractAccountCode__c);
    }
    
    
    //TESTS
    
    //getCaseById
    @isTest
    private static void getCaseByIdTest(){
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        
        //TESTING
        HDT_QR_PaymentCommunication myObjectToTest = new HDT_QR_PaymentCommunication();
        Case result = myObjectToTest.getCaseById(myCase.Id);
        
        //ASSERTS
        System.assertEquals(myCase.Id, result.Id, 'Test fallito.');
        
    }
    
    //getCaseById
    @isTest
    private static void getDocumentSelectedByCaseTest(){
        
        //SETUP
        mySetup();
        Case myCase = [SELECT Id FROM Case];
        DocumentSelected__c myDocSelected = [SELECT Id FROM DocumentSelected__c];
        
        //TESTING
        HDT_QR_PaymentCommunication myObjectToTest = new HDT_QR_PaymentCommunication();
        DocumentSelected__c result = myObjectToTest.getDocumentSelectedByCase(myCase.Id)[0];
        
        //ASSERTS
        System.assertEquals(myDocSelected.Id, result.Id, 'Test fallito.');
        
    }
    
}
