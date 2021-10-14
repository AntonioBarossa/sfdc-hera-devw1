@isTest
public with sharing class HDT_DocumentalActivityTst {
    @isTest
    public static void testDocumentalActivity() {


        List<Account> testAcc =  HDT_UTL_DataFactoryTst.createAccountPartner(1, false , 'testact');
        testAcc[0].CompanyOwner__c  = 'HERA COMM';
        insert testAcc;

        id acctId = testAcc[0].id;

        List<Contact> testCont =  HDT_UTL_DataFactoryTst.createContact(1, true, acctId);

        id contId = testCont[0].Id;

        List<Order>  orderTest = HDT_UTL_DataFactoryTst.createOrder(1,true,acctId,'Bozza');

        id orderId = orderTest[0].Id;

        List<ServicePoint__c> testServ =  HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        id servId = testServ[0].Id;

        List<Contract> testContr = HDT_UTL_DataFactoryTst.createContract(1, true, acctId);

        id contrId = testContr[0].Id;

        List<Case> caseTest = HDT_UTL_DataFactoryTst.createCase( 1, true, acctId, contId, servId, contrId, orderId );

        id caseId = caseTest[0].Id;

        List<DocumentalActivity__c> docActTest = HDT_UTL_DataFactoryTst.createDocumentalActivity(10, orderId, caseId );

        id docId = docActTest[0].id;

        System.assertEquals(true , docId != null , 'trigger on DocumentalActivity__c is not creating the list');
        system.assertNotEquals('', docId ,'trigger on DocumentalActivity__c is not creating the list');
    }
}
