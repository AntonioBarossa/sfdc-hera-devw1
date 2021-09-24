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
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].Type = 'Sollecito Emissione Bolletta';
        caseList[1].Type = 'Unificazione/Separazione BP-CA-Bolletta';
        insert caseList;

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
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Da Inviare', rtId, rtName,'C',calloutTemplates[0].wrts_prcgvr__Code__c,'requestType=CREA_RIC;','HDT_SRV_HerokuPostSalesManager(method="execute");');
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
        /*SObject transition;
        SObject action;
        String method = 'execute';
        Map<String, String> parameters = new Map<String,String>();
        Map<String,Object> args = new Map<String,Object>{
            'transition' => transition,
            'action' => action,
            'method' => method,
            'sender' => testCase,
            'parameters' => parameters
        };*/
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        Test.startTest();
        //response = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) herokuSrv.execute(args);
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c);
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
        System.assertEquals(richPassCase.size(), 3);
    }   
    @isTest
    static void handleRichPassResponseFieldTst()
    {
        Case testCase = [SELECT AccountId, ContactId, ServicePoint__c, Contract__c, Order__c, CaseNumber, Phase__c, Type FROM Case LIMIT 1];
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, testCase.AccountId, testCase.ContactId, testCase.ServicePoint__c, testCase.Contract__c, testCase.Order__c);
        testCase.ParentId = caseList[0].Id;
        update testCase;
        testCase = [SELECT Parent.CaseNumber, CaseNumber, Phase__c, Type FROM Case WHERE Id = : testCase.Id LIMIT 1];
        List<HDT_WRP_MrrResponse.HDT_WRP_Field> responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        Test.startTest();
        responseFieldList = herokuSrv.handleRichPassResponseField(testCase);
        Test.stopTest();
        System.Assert(responseFieldList != null);
    }
    @isTest
    static void handleNotifEsResponseFieldTst()
    {
        Case testCase = [SELECT CaseNumber, Phase__c, Type,HerokuPracticeCode__c FROM Case LIMIT 1];
        List<HDT_WRP_MrrResponse.HDT_WRP_Field> responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        Test.startTest();
        responseFieldList = herokuSrv.handleNotifEsResponseField(testCase);
        Test.stopTest();
        System.Assert(responseFieldList != null);
    }

    //INIZIO Test method per classe HDT_SRV_DataEnrichmentPostSales

    @isTest
    static void testGetPicklistValue(){

        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        String result = c.getPicklistValue('Case', 'PhaseTypeAvailable__c', '0.8');
        System.assert('Monofase'.equals(result), 'result != Monofase');

        String result2 = c.getPicklistValue('Case', 'PhaseTypeAvailable__c', '1.1');
        System.assert('Trifase'.equals(result2), 'result != Monofase');

        String result3 = c.getPicklistValue('Case', 'Taxes__c', 'E_IMPOST');
        System.assert('Imposta usi domestici'.equals(result3), 'result != Monofase');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetBoolFromString(){
        
        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        Boolean result = c.getBoolFromString('SI');
        System.assertEquals(true, result, 'result != true');

        Boolean result2 = c.getBoolFromString('NO');
        System.assertEquals(false, result2, 'result != true');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetDateByYear(){
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        Date dt = c.getDateByYear('2021');
        System.debug('Data: ' + dt);

        System.assertEquals('2021-01-01', String.valueOf(dt), 'dt != 2021-01-01');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetBillingProfileIdBySapCode(){
        
        Test.startTest();
            
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        BillingProfile__c billProfile = [Select Id, ContractAccountCode__c FROM BillingProfile__c LIMIT 1];

        String result = c.getBillingProfileIdBySapCode(billProfile.ContractAccountCode__c);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetDeliveryAddress(){
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        BillingProfile__c billProfile = [SELECT Id FROM BillingProfile__c LIMIT 1];

        String result = c.getDeliveryAddress(billProfile.Id);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testCalculateSalesCompany(){
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();


        String result = c.calculateSalesCompany('13V0000000');
        System.assertEquals('Hera Comm S.p.A.', result, 'result != Hera Comm S.p.A.');

        String result2 = c.calculateSalesCompany('10V0000160');
        System.assertEquals('Hera Comm Marche', result2, 'result != Hera Comm S.p.A.');

        Test.stopTest();
        
    }

    @IsTest
    static void testGetCaliber(){

        List<String> caliberValues = new List<String>();
        caliberValues.add('GRT005');
        caliberValues.add('GRT010');
        caliberValues.add('GRT015');
        caliberValues.add('GRT006');
        caliberValues.add('GRT011');
        caliberValues.add('GRT016');
        caliberValues.add('GRT002');
        caliberValues.add('GRT007');
        caliberValues.add('GRT012');
        caliberValues.add('GRT003');
        caliberValues.add('GRT008');
        caliberValues.add('GRT013');
        caliberValues.add('GRT017');
        caliberValues.add('GRT004');
        caliberValues.add('GRT009');
        caliberValues.add('GRT014');
        caliberValues.add('GRT018');
        
        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();


        for (String caliber : caliberValues){

            String result = c.getCaliber(caliber);

            System.assert(!String.isBlank(result), 'result is blank for caliber: ' + caliber);

        }

        Test.stopTest();
        
    }

    @IsTest
    static void testGetOpzione(){

        
        List<String> options = new List<String>{'E_UD_TDR','E_UD_TDNR','E_MTIP','E_BTIP','E_MTA1','E_BTA1','E_MTA3','E_MTA2','E_BTA6','E_BTA5','E_BTA4','E_BTA3','E_BTA2','E_ALTA'};
        
        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        for (String option : options){

            String result = c.getOpzione(option);
            System.assert(!String.isBlank(result), 'result is blank for option: ' + option);

        }

        Test.stopTest();
        
    }

    @IsTest
    static void testWriteBlockCode(){


        Case currentCase = [Select Id, Type FROM Case WHERE Type = 'Sollecito Emissione Bolletta'];

        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        String result = c.writeBlockCode('Sap Valute Test', currentCase);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testWriteCollectiveBillType(){


        Case currentCase = [Select Id, Type FROM Case WHERE Type = 'Unificazione/Separazione BP-CA-Bolletta'];

        Test.startTest();
        
        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        String result = c.writeCollectiveBillType('Sap Valute Test', currentCase);

        System.assert(!String.isBlank(result), 'result is blank');

        Test.stopTest();
        
    }

    @IsTest
    static void testPopulateCase(){
        
        Case currentCase = [Select Id, Type FROM Case WHERE Type = 'Unificazione/Separazione BP-CA-Bolletta'];

        Test.startTest();

        HDT_SRV_DataEnrichmentPostSales c = new HDT_SRV_DataEnrichmentPostSales();

        Map<String, Object> transcodeMap = new Map<String, Object>();
        transcodeMap.put('FirstName__c', 'Test');

        Case cs = c.populateCase(transcodeMap, currentCase);

        System.assertEquals('Test', cs.FirstName__c, 'cs.FirstName__c != Test');

        Test.stopTest();
        
    }

    //FINE Test method per classe HDT_SRV_DataEnrichmentPostSales


    //INIZIO Test Costruttori classe HDT_WRP_HerokuPostSalesManager
    @IsTest
    static void testFirstConstructorHerokuPostSalesManager(){
        
        Test.startTest();
        HDT_WRP_HerokuPostSalesManager wrapper = new HDT_WRP_HerokuPostSalesManager('test', 'result','errorMessage', 'refReq', 'communicationChannel', 'reqId', 'herokuCode', 'dlCode');

        System.assertEquals('test', wrapper.responseMap.get('requestType'), 'requestType != test');

        Test.stopTest();
        
    }

    @IsTest
    static void testSecondConstructorHerokuPostSalesManager(){
        
        Test.startTest();

        HDT_WRP_HerokuPostSalesManager wrapper = new HDT_WRP_HerokuPostSalesManager('flowTest', 'phase','idTest', 'herokuCode', 'dlCode', 'codiceContrattoTest', 'contractStatus');

        System.assertEquals('idTest', wrapper.requestMap.get('recordId'), 'recordId != idTest');
        System.assertEquals('codiceContrattoTest', wrapper.requestMap.get('contractCode'), 'contractCode != codiceContrattoTest');

        Test.stopTest();
        
    }

    //FINE Test Costruttori classe HDT_WRP_HerokuPostSalesManager

}
