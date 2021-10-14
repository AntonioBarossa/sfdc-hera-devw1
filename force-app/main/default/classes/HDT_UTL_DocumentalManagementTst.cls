@isTest
public with sharing class HDT_UTL_DocumentalManagementTst {
    @TestSetup
    static void setup(){

        // List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        // List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        // List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        // List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        // List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        // List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        // List<DocumentalPayloadAdministration__c> documList = HDT_UTL_DataFactoryTst.createDocumentalPayloadAdm();
        // List<DocumentalActivity__c> docActList = HDT_UTL_DataFactoryTst.createDocumentalActivity(1,null,caseList[0].Id);
        // HDT_UTL_DataFactoryTst.createJsonPayload();
        // HDT_UTL_DataFactoryTst.createDriverJson();
    }

    @isTest
    static void testManageAmount() {
        Test.startTest();

        String originalAmount = '186.38';
        String expectedAmount = '186,38';
        
        String managedAmount = HDT_UTL_DocumentalManagement.manageAmountDot(originalAmount);
        System.assertEquals(expectedAmount, managedAmount,'Manage Amount OK');

        originalAmount = '38';
        expectedAmount = '38,00';
        
        managedAmount = HDT_UTL_DocumentalManagement.manageAmountDot(originalAmount);
        System.assertEquals(expectedAmount, managedAmount,'Manage Amount OK');

        originalAmount = '';
        expectedAmount = '0,00';
        
        managedAmount = HDT_UTL_DocumentalManagement.manageAmountDot(originalAmount);
        System.assertEquals(expectedAmount, managedAmount,'Manage Amount OK');

        Test.stopTest();
    }
}
