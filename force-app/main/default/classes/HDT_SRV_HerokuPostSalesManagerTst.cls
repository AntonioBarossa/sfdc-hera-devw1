@isTest
public with sharing class HDT_SRV_HerokuPostSalesManagerTst {

    @TestSetup
    static void setup(){
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
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
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza', 'Bozza', rtId, rtName,'C',calloutTemplates[0].wrts_prcgvr__Code__c,'requestType=CREA_RIC;','HDT_SRV_HerokuPostSalesManager(method="execute");');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku KO', 'Bozza', rtId, rtName,'A','','','');
    }
    @isTest
    static void executeTst()
    {
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        SObject transition;
        SObject action;
        String method = 'execute';
        Map<String, String> parameters = new Map<String,String>();
        Map<String,Object> args = new Map<String,Object>{
            'transition' => transition,
            'action' => action,
            'method' => method,
            'sender' => testCase,
            'parameters' => parameters
        };
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        response = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) herokuSrv.execute(args);
        Test.stopTest();
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, Status FROM Case LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.Phase__c);
        System.assertEquals('00002349', testCaseUpd.HerokuPracticeCode__c);
        
    }
    @isTest
    static void updatefutureTst()
    {   
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        Test.startTest();
        testCase.Phase__c = 'Comunicazione verso Heroku OK';
        HDT_SRV_HerokuPostSalesManager.updateFuture(JSON.serialize(testCase));
        Test.stopTest();
        Case testCaseUpd = [SELECT Id, Phase__c FROM Case LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.Phase__c);
    }
    @isTest
    static void handleInboundRequestTst()
    {
        Case testCase = [SELECT Id, CaseNumber, Phase__c, Type FROM Case LIMIT 1];
        HDT_WRP_MrrRequest.HDT_WRP_Request notifEs = new HDT_WRP_MrrRequest.HDT_WRP_Request();
        HDT_WRP_MrrRequest.HDT_WRP_Request richPass = new HDT_WRP_MrrRequest.HDT_WRP_Request();
        HDT_WRP_MrrRequest.HDT_WRP_Request richKo = new HDT_WRP_MrrRequest.HDT_WRP_Request();
        String notifEsString = HDT_UTL_DataFactoryTst.notifEsReq('postsales',testCase.Id, 'Comunicazione verso Heroku OK','esito_intermedio');
        String richPassString = '{"header":null,"requests":[{"header":{"requestId":null,"requestTimestamp":null,"requestType":"RICH_PASS","fields":['
        +'{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"objects":[{"fields":['
        +'{"fieldType":"TEXT","name":"CODICE_PRESA", "value":""},'
        +'{"fieldType":"TEXT","name":"CODICE_CLIENTE", "value":"1006322046"},'
        +'{"fieldType":"TEXT","name":"CONTO_CONTRATTUALE", "value":"200005882313"},'
        +'{"fieldType":"TEXT","name":"CODICE_CONTRATTO", "value":"3020243910"},'
        +'{"fieldType":"TEXT","name":"TIPO_SIEBEL", "value":"Credito"},'
        +'{"fieldType":"TEXT","name":"SOTTOTIPO_SIEBEL", "value":"Morosita"},'
        +'{"fieldType":"TEXT","name":"COD_FISCALE", "value":"RSSSLD50D25G453V"},'
        +'{"fieldType":"TEXT","name":"RECAPITO", "value":"3401540441"},'
        +'{"fieldType":"TEXT","name":"PROCESS_TYPE", "value":"Sospensione Fornitura"},'
        +'{"fieldType":"TEXT", "name":"UFFICIO_COMPETENTE","value":"HCM"}'
        +'],"id":null,"name":null,"objectType":null,"objects":null}]}]}';
    }
    @isTest
    static void handleRichPassResponseFieldTst()
    {
        
    }
    @isTest
    static void handleNotifEsResponseFieldTst()
    {
        
    }

}
