@isTest
public with sharing class HDT_DocumentSendTrackingTst {
    @isTest
    public static void testDocumentSendTracking() {



        List<Account> testAcc =  HDT_UTL_DataFactoryTst.createAccountPartner(1, false , 'testact');
        testAcc[0].CompanyOwner__c  = 'HERA COMM';
        insert testAcc;

        id acctId = [SELECT id FROM Account WHERE id =: testAcc[0].id ].Id;

        List<Contact> testCont =  HDT_UTL_DataFactoryTst.createContact(1, true, acctId);

        id contId = [SELECT id FROM Contact WHERE id =: testCont[0].Id ].id;

        List<Order>  orderTest = HDT_UTL_DataFactoryTst.createOrder(1,true,acctId,'Bozza');
        
        id orderId = [SELECT id FROM Order WHERE id =: orderTest[0].id ].Id;

        List<ServicePoint__c> testServ =  HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        id servId = [SELECT id FROM ServicePoint__c WHERE id =: testServ[0].id ].Id;

        List<Contract> testContr = HDT_UTL_DataFactoryTst.createContract(1, true, acctId);

        id contrId = [SELECT id FROM Contract WHERE id =: testContr[0].id ].Id;

        List<Case> caseTest = HDT_UTL_DataFactoryTst.createCase( 1, true, acctId, contId, servId, contrId, orderId );

        id caseId = [SELECT id FROM Case WHERE id =: caseTest[0].id ].Id;

        list<DocumentSendTracking__c> testDocSendTr =  HDT_UTL_DataFactoryTst.createDocumentSendTracking(10, orderId, caseId);

        id docId = [SELECT id FROM DocumentSendTracking__c WHERE id =: testDocSendTr[0].id ].id;

        System.assertEquals(true, docId != null, 'trigger on DocumentSendTracking__c is not creating the list');
        System.assertNotEquals('', docId, 'trigger on DocumentSendTracking__c is not creating the list');

    }
}
