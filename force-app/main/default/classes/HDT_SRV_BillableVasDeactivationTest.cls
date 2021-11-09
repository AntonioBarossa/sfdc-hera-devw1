/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 28-10-2021
 * @last modified by  : federico.defelice@webresults.it
**/
@isTest public with sharing class HDT_SRV_BillableVasDeactivationTest {


    @TestSetup
    static void setup(){
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].DistributorPracticeCode__c = 'A00000000288_DL';
        ordList[0].ServicePoint__c = servPointList[0].Id;
        insert ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id,contactList[0].Id);
        
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false, accList[0].Id);
        billingProfileList[0].InvoicingStreetName__c = 'Roma';
        billingProfileList[0].InvoicingStreetNumber__c = '15';
        billingProfileList[0].InvoicingStreetNumberExtension__c = '20100 ITALIA';
        billingProfileList[0].InvoicingCity__c = 'ROMA';
        billingProfileList[0].InvoicingProvince__c = 'RM';
        billingProfileList[0].InvoicingPostalCode__c = '10190';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';

        insert billingProfileList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);

        List<wrts_prcgvr__ActivityTemplate__c> actTempList = new List<wrts_prcgvr__ActivityTemplate__c>();

        wrts_prcgvr__ActivityTemplate__c actTemplate1 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate1.Name = 'Recesso Anticipato';
        actTemplate1.wrts_prcgvr__Subject__c = 'Recesso Anticipato';

        wrts_prcgvr__ActivityTemplate__c actTemplate2 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate2.Name = 'Eseguire Gestione Manuale SAP';
        actTemplate2.wrts_prcgvr__Subject__c = 'Eseguire Gestione Manuale SAP';

        actTempList.add(actTemplate1);
        actTempList.add(actTemplate2);
        insert actTempList;

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].Type = 'Sollecito Emissione Bolletta';
        caseList[0].EarlyRecess__c = true;
        caseList[1].Type = 'Unificazione/Separazione BP-CA-Bolletta';
        caseList[1].EarlyRecess__c = true;
        insert caseList;

        Case parentCase = [SELECT Id FROM Case WHERE Type = 'Sollecito Emissione Bolletta'];
        List<Case> caseList2 = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList2[0].ParentId = parentCase.Id;
        caseList2[0].Type = 'Sospensione Fornitura';
        insert caseList2;

        List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', 
        '{"name": "Case","label": "Caso","sObjectType": "Case","queryable": true,"fields": ['
        +'{"name": "CreatedDate","label": "DT_RIC_UTENTE"},'
        +'{"name": "CaseNumber","label": "RIF_RICH"},'
        +'{"name": "Type","label": "TIPO_OPERAZIONE"},'
        +'{"name": "Id","label": "RECORD_ID"}'
        +']}'
        ,'Callout_Template.json');
        List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates = HDT_UTL_DataFactoryTst.createCalloutTemplate(1,true,'Callout_Prova','prova',true,'Case','Flat',contentVersionList[0].ContentDocumentId);
        HDT_UTL_DataFactoryTst.createEndpointRule(1, true, 'Prova');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Da Inviare', rtId, rtName,'C',calloutTemplates[0].wrts_prcgvr__Code__c,'requestType=CREA_RIC;','HDT_SRV_BillableVasDeactivation(method="execute");');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku KO', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SII', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In Lavorazione', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Annullamento - Comunicazione verso Heroku OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviato al DL', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Comunicazione verso Heroku OK', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza', 'Inviato al DL', rtId, rtName,'A','','','');
        
        String rtNameAnagr =  'HDT_RT_AllineamentoAnagrafica';
        String rtIdAnagr = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviato al DL', 'Bozza', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Annullato SII', 'Bozza', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza', 'Inviato al DL', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Comunicazione verso Heroku OK', rtIdAnagr, rtNameAnagr,'A','','','');

        String rtNamePianoRat =  'HDT_RT_PianoRateizzazione';
        String rtIdPianoRat = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Acconto paperless pagato', 'Bozza', rtIdPianoRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviato al DL', 'Bozza', rtIdPianoRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Comunicazione verso Heroku OK', rtIdPianoRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza', 'Inviato al DL', rtIdPianoRat, rtNamePianoRat,'A','','','');


        wrts_prcgvr__AsyncJob__c asyncJob = new wrts_prcgvr__AsyncJob__c();
        asyncJob.wrts_prcgvr__JobItem__c = 'test';
        asyncJob.wrts_prcgvr__Status__c = 'Completed';
        insert asyncJob;

    }
    
    @isTest
    static void testQueueableUpdate(){
        new HDT_SRV_BillableVasDeactivation.HDT_QBL_UpdateQueueable();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        testCase.type='Disattivazione VAS';
        HDT_SRV_BillableVasDeactivation.HDT_QBL_UpdateQueueable q2 = new HDT_SRV_BillableVasDeactivation.HDT_QBL_UpdateQueueable(testCase);
        test.startTest();
        system.enqueueJob(q2);
        test.stopTest();
        testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case where id=:testCase.Id LIMIT 1];
        system.assertEquals(testCase.Type, 'Disattivazione VAS', 'Unexpected CaseType');
    }


    @isTest
    static void executeCallout1(){
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
                +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
                +'},"code":null,"description":null,'
                +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
                +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
                +'{"fieldType":"TEXT","name":"COD_PRAT_UTENTE","value":"012354"},'
                +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
                +'{"fieldType":"TEXT","name":"rifRich","value":""},'
                +'{"fieldType":"TEXT","name":"COD_PRAT_DISTR","value":"345345"},'
                +'{"fieldType":"TEXT","name":"DT_INVIO_DL","value":"'+ Date.today() +'"},'
                +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
                +'{"fieldType":"TEXT","name":"FASE","value":""},'
                +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
                +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
                'statuscode' => '200'
            }
        };
        
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_SRV_HerokuPostSalesManagerTst.HDT_WS_PostSalesTstMock2(responseMap));
        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('21313232132132', testCaseUpd.HerokuPracticeCode__c, 'Unexpected HerokuPracticeCode__c');
        
    }

    @isTest
    static void executeCallout2(){
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"012354","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
                +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
                +'},"code":null,"description":null,'
                +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
                +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
                +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
                +'{"fieldType":"TEXT","name":"rifRich","value":""},'
                +'{"fieldType":"TEXT","name":"COD_PRAT_DISTR","value":"345345"},'
                +'{"fieldType":"TEXT","name":"DT_INVIO_DL","value":"'+ Date.today() +'"},'
                +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
                +'{"fieldType":"TEXT","name":"FASE","value":""},'
                +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
                +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
                'statuscode' => '200'
            }
        };
        
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_SRV_HerokuPostSalesManagerTst.HDT_WS_PostSalesTstMock2(responseMap));
        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('21313232132132', testCaseUpd.HerokuPracticeCode__c, 'Unexpected HerokuPracticeCode__c');
        
    }
    
    @isTest
    static void executeCallout3KO(){
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"012354","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
                +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
                +'},"code":null,"description":null,'
                +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
                +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
                +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
                +'{"fieldType":"TEXT","name":"rifRich","value":""},'
                +'{"fieldType":"TEXT","name":"COD_PRAT_DISTR","value":"345345"},'
                +'{"fieldType":"TEXT","name":"DT_INVIO_DL","value":"'+ Date.today() +'"},'
                +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
                +'{"fieldType":"TEXT","name":"FASE","value":""},'
                +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
                +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
                'statuscode' => '200'
            }
        };
        
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_SRV_HerokuPostSalesManagerTst.HDT_WS_PostSalesTstMock2(responseMap));
        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('21313232132132', testCaseUpd.HerokuPracticeCode__c, 'Unexpected HerokuPracticeCode__c');
        
    }
    
    @isTest
    public static Void postNotifEs() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"requests": [{"header": {"requestId": "","requestTimestamp": "","requestType": "NOTIF_ES"},"objects": [{"fields": [{"fieldType": "","name": "SALESFORCE_KEY","value": ""}, {"fieldType": "","name": "RECORD_ID","value": "O-12345"}],"id": "","name": "","objects": [],"objectType": "Case"}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();
        
        String body = RestContext.request.requestBody.toString();

        HDT_WRP_MrrRequest requestBody = (HDT_WRP_MrrRequest) JSON.deserialize(body, HDT_WRP_MrrRequest.class);
        
                    
        HDT_SRV_BillableVasDeactivation.handlerAsyncronousNotify(requestBody.requests[0]);
        
        Map<String,String> mapRequestFields = getMapFields(requestBody.requests[0]);
        String recordIdAfter = mapRequestFields.get('RECORD_ID');

		system.assertEquals(recordIdAfter, 'O-12345', 'Unexpected RECORD_ID key');
    }
    
    
    private static Map<String,String> getMapFields(HDT_WRP_MrrRequest.HDT_WRP_Request request){
        Map<String,String> mapRequestFields = new Map<String,String>();
        if (request?.objects?.size()> 0 && request?.objects?.get(0)?.fields?.size() > 0) {
            for(HDT_WRP_MrrRequest.HDT_WRP_Field field : request.objects.get(0).fields){
                if(mapRequestFields.get(field.name) == null){
                    mapRequestFields.put(field.name,field.value);
                }
            }
        }
        return mapRequestFields;
    }
}