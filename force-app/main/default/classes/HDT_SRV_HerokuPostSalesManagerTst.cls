@isTest
public with sharing class HDT_SRV_HerokuPostSalesManagerTst {

    @TestSetup
    static void setup(){
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        AccountContactRelation accountContactRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id,contactList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
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
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In Lavorazione', 'Bozza', rtId, rtName,'A','','','');
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
        //Declaration
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObj = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObjPass = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrRequest notifEs = new HDT_WRP_MrrRequest();
        HDT_WRP_MrrRequest richPass = new HDT_WRP_MrrRequest();
        HDT_WRP_MrrRequest richKo = new HDT_WRP_MrrRequest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Integer statusCode;
        RestContext.request = req;
        RestContext.response = res;
        //Entity Query
        AccountContactRelation testAccount = [SELECT Account.CustomerCode__c,AccountId, ContactId, Roles FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];
        ServicePoint__c testSp = [SELECT Name,ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Contract testContract = [SELECT SAPContractCode__c FROM Contract WHERE AccountId = :testAccount.AccountId];
        BillingProfile__c testBillingProfile = [SELECT ContractAccountCode__c FROM BillingProfile__c LIMIT 1];
        Case testCase = [SELECT CaseNumber, Phase__c, Type FROM Case LIMIT 1];
        //Update ServicePoint Commodity
        testSp.CommoditySector__c = 'Energia Elettrica';
        update testSp; 
        testContract.ServicePoint__c = testSp.Id;
        testContract.Status = 'Attivo';
        update testContract;
        //Create Requests
        String notifEsString = HDT_UTL_DataFactoryTst.notifEsReq('postsales',testCase.Id, 'Comunicazione verso Heroku OK','esito_intermedio');
        String richPassString = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, 
            testContract.SAPContractCode__c, 'Morosita', 'Sospensione Fornitura', '', 'Da PGM', '20220102', '', '');
        String notifEsKo = HDT_UTL_DataFactoryTst.notifEsReq('postsales',testCase.Id, 'Completata','esito_finale');
        notifEs = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsString, HDT_WRP_MrrRequest.class);
        richKo  = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsKo, HDT_WRP_MrrRequest.class);
        richPass = (HDT_WRP_MrrRequest) JSON.deserialize(richPassString, HDT_WRP_MrrRequest.class);
        //SetMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        //Test
        Test.startTest();
        responseObj = herokuSrv.handleInboundRequest(notifEs.requests[0]);
        responseObj = herokuSrv.handleInboundRequest(richKo.requests[0]);
        statusCode = res.statusCode;
        responseObjPass = herokuSrv.handleInboundRequest(richPass.requests[0]);
        Test.stopTest();
        //Assertions
        Case testCaseUpd = [SELECT CaseNumber, Phase__c, Type FROM Case WHERE Type = :testCase.Type LIMIT 1];
        List<Case> richPassCase = [SELECT CaseNumber, Phase__c, Type FROM Case WHERE Type != :testCase.Type];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.Phase__c);
        System.assertEquals(statusCode, 400);
        System.assertEquals(richPassCase.size(), 2);
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
