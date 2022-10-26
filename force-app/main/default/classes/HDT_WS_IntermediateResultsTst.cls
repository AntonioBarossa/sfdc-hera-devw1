/**
 * @description       : 
 * @author            : Carmine Scalise
 * @group             : 
 * @last modified on  : 25-10-2022
 * @last modified by  : Carmine Scalise
**/
@isTest
private class HDT_WS_IntermediateResultsTst {
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    private static HDT_QR_Case caseQr = new HDT_QR_Case();

    @TestSetup
    static void setup() {

        Id processTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);

        //CASE PHASE MANAGEMENT ENABLE
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        
        HDT_UTL_DataFactoryTst.newPhaseTransition('Approvata', 'Inviata a SAP', processTypeId, 'HDT_RT_Segnalazioni');
            
        //CASE - INSERT - PAGAMENTI - PIANO RATEIZZAZIONE
        Case myCase = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        myCase.salesCompany__c='Hera Comm Marche';
        myCase.RecordTypeId = processTypeId;
        myCase.Phase__c = 'Inviata a SAP';
        myCase.Type = 'Avviso di Servizio';
        insert myCase;
    }

    @isTest
    public static void testIntermediateResultsJob() {

        // HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
		// HDT_WS_IntermediateResults intermediario = new HDT_WS_IntermediateResults();
        // Test.setMock(HttpCalloutMock.class, mock);

        Case myCase = [SELECT Id FROM Case];
        System.debug('myCase => '+myCase);

        HDT_WS_IntermediateResults.HDT_WRP_Field fieldObj = new HDT_WS_IntermediateResults.HDT_WRP_Field();
        fieldObj.codActivity = '';
        fieldObj.codNota = '0050';
        fieldObj.descNota = '';
        fieldObj.textNota = '';
        fieldObj.phase = 'Approvata';

        List<HDT_WS_IntermediateResults.HDT_WRP_Field> fieldList = new List<HDT_WS_IntermediateResults.HDT_WRP_Field>();
        fieldList.add(fieldObj);

        HDT_WS_IntermediateResults.HDT_WRP_Reminder reminderObj = new HDT_WS_IntermediateResults.HDT_WRP_Reminder();
        reminderObj.caseId = myCase.Id;
        reminderObj.noticeId = '';
        reminderObj.field = fieldList;

        List<HDT_WS_IntermediateResults.HDT_WRP_Reminder> reminderList = new List<HDT_WS_IntermediateResults.HDT_WRP_Reminder>();
        reminderList.add(reminderObj);

        HDT_WS_IntermediateResults.HDT_WRP_Request request = new HDT_WS_IntermediateResults.HDT_WRP_Request();
        request.requestId = '';
        request.dataRequest = '';
        request.reminder = reminderList;

         //test
         Test.startTest();

         //setup for test
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse();
 
         String reqString = JSON.serialize(request);
         req.requestURI = 'services/apexrest/IntermediateResults';
         req.httpMethod = 'POST';
         req.requestBody = Blob.valueOf(reqString);  
 
         RestContext.request = req;
         RestContext.response = res;

         //call webservice method
         HDT_WS_IntermediateResults.postIntermediateResults();
         res = RestContext.response;
         Test.StopTest();
        

    }

    public class HDT_WS_IntermediateResultsTstHTTPMock implements HttpCalloutMock {
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