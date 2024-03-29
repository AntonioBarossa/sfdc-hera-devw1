/**
 * @description       : 
 * @author            : Carmine Scalise
 * @group             : 
 * @last modified on  : 25-10-2022
 * @last modified by  : Carmine Scalise
**/
@isTest
private class HDT_WS_IntermediateResultsTst {

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
        HDT_UTL_DataFactoryTst.newPhaseTransition('Bozza', 'Bozza', processTypeId, 'HDT_RT_Segnalazioni');

        //CASE - INSERT
        Case myCase = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id)[0];
        myCase.salesCompany__c = 'Hera Comm Marche';
        myCase.RecordTypeId = processTypeId;
        myCase.Phase__c = 'Inviata a SAP';
        myCase.Type = 'Avviso di Servizio';
        myCase.Order__c = ordList[0].Id;
        insert myCase;
    }

    @isTest
    public static void testIntermediateResultsJob() {

        Order myOrder = [SELECT Id FROM Order];
        
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

    @isTest
    public static void getPhaseByCodeTest() {
        HDT_WS_IntermediateResults.HDT_WRP_Response responseError = new HDT_WS_IntermediateResults.HDT_WRP_Response('status', 'error');
        system.assertEquals(
            'error',
            responseError.errorMsg,
            'messaggio errore errato'
        );
        HDT_WS_IntermediateResults.HDT_QBL_IntermediateResultsJob res = new HDT_WS_IntermediateResults.HDT_QBL_IntermediateResultsJob(null);
        system.assertEquals(
            'Presa In Carico',
            res.getIstruttoriaFaseByCode('0060'),
            'Coppia Fase-Codice Inaspettata'
        );
        system.assert(
            res.getIstruttoriaFaseByCode('#####') == null,
            'Coppia Fase-Codice Inaspettata'
        );
    }

    @isTest
    public static void testIntermediateResultsJob2() {

        Order myOrder = [SELECT Id FROM Order];
        
        Case myCase = [SELECT Id FROM Case];
        System.debug('myCase => '+myCase);

        HDT_WS_IntermediateResults.HDT_WRP_Field fieldObj = new HDT_WS_IntermediateResults.HDT_WRP_Field();
        fieldObj.codActivity = '';
        fieldObj.codNota = '0007';
        fieldObj.descNota = '';
        fieldObj.textNota = '';
        fieldObj.phase = 'Rifiutata';

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

    @isTest
    public static void testInvalidNoteCode() {

        Order myOrder = [SELECT Id FROM Order];
        
        Case myCase = [SELECT Id FROM Case];
        System.debug('myCase => '+myCase);

        HDT_WS_IntermediateResults.HDT_WRP_Field fieldObj = new HDT_WS_IntermediateResults.HDT_WRP_Field();
        fieldObj.codActivity = '';
        fieldObj.codNota = '#####';
        fieldObj.descNota = '';
        fieldObj.textNota = '';
        fieldObj.phase = 'Completata';

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