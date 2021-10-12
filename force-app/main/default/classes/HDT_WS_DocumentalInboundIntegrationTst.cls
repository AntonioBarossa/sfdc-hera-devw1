@isTest
public with sharing class HDT_WS_DocumentalInboundIntegrationTst {
    
    @TestSetup
    static void setup(){

        //SETUP
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].Cluster__c = 'Preventivi';
        caseList[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PreventiviEle').getRecordTypeId();
        insert caseList;

        String rtName = 'HDT_RT_PreventiviEle';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PreventiviEle').getRecordTypeId();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Preventivo accettato', 'Bozza', rtId, rtName,'A','','','');

        DocumentSendTracking__c myDoc = HDT_UTL_DataFactoryTst.createDocumentSendTracking(1, ordList[0].Id, caseList[0].Id)[0];
    }

    @IsTest
    static void testDocusignNotify(){
        
        //test
        Test.startTest();

        //setup for test
        RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

        String reqString = '{"outcome":"OK","outcomeDescription":"OK", "status":"completed", "envelopeId":"idPlico_0"}';
        req.requestURI = 'services/apexrest/DocumentalInboundServices';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(reqString);  

		RestContext.request = req;
		RestContext.response = res;

        //mock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_DocumentalInboundIntegrationTstHTTPMock());
        //call webservice method
        HDT_WS_DocumentalInboundIntegration.docusignNotify();
        res = RestContext.response;

        //assertions
        Case updatedCase = [SELECT Id, Phase__c FROM Case LIMIT 1];
        System.assertEquals('Preventivo accettato', updatedCase.Phase__c, 'Phase__c != Preventivo accettato');
        DocumentalActivity__c docAct = [SELECT Id FROM DocumentalActivity__c WHERE ActivityType__c = 'Documentazione completa' LIMIT 1];
        System.assertNotEquals(null, docAct, 'docAct == null');
        
        Test.stopTest();
        
    }

    public class HDT_WS_DocumentalInboundIntegrationTstHTTPMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"OK", "data":{"transactionId":"idPlico_0"}}');
            res.setStatus('OK');
            res.setStatusCode(200);
            return res;
        }
    }
}
