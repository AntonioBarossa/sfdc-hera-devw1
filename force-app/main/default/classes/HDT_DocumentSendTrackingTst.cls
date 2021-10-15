/**

Header of the class "HDT_ClassNameTst"
@author Pooyan Ghadiri Abkenar, pooyan.ghadiriabkenar@webresults.it
@Version 1.0
@description: Apex Test Class of the relative Apex Class "HDT_DocumentSendTracking"
@history
@created 12/10/2021
Modified By:
**/

@isTest
public with sharing class HDT_DocumentSendTrackingTst {
    @isTest
    public static void testDocumentSendTracking() {

        List<Account> testAcc =  HDT_UTL_DataFactoryTst.createAccountPartner(1, false , 'testact');
        testAcc[0].CompanyOwner__c  = 'HERA COMM';
        insert testAcc;

        id acctId = testAcc[0].Id;

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

        list<DocumentSendTracking__c> testDocSendTr =  HDT_UTL_DataFactoryTst.createDocumentSendTracking(10, orderId, caseId);

        id docId = testDocSendTr[0].id;

        System.assertEquals(true, docId != null, 'trigger on DocumentSendTracking__c is not creating the list');
        System.assertNotEquals('', docId, 'trigger on DocumentSendTracking__c is not creating the list');

    }
}
