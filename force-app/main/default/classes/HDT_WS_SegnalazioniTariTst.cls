/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 03-30-2023
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_WS_SegnalazioniTariTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makeData(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

        System.runAs(internalUser){

            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('MulesoftHergoNotice', 'Callout:MulesoftHergoPath/notice', 'POST', 'MulesoftSalesforceUser');

            wrts_prcgvr.InstallIntegration.install();
            wrts_prcgvr.VersionManager.newClassInstance('CalloutTemplateMng');
            wrts_prcgvr.VersionManager.newClassInstance('EndpointRulesIntegration');
            wrts_prcgvr.VersionManager.newClassInstance('CalloutClient');
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickCasePhase();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            
            HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza',constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI,constants.CASE_RECORDTYPE_DEVELOPERNAME_GENERICHE_ATTIVAZIONI);
            // HDT_UTL_DataFactoryTst.newPhaseTransition('Inviata a SAP', 'Bozza', constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI, constants.CASE_RECORDTYPE_DEVELOPERNAME_GENERICHE_ATTIVAZIONI);
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accs[1].CustomerCode__c = null;
            insert accs;

            List<BillingProfile__c> billings = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accs[0].Id);
            
            Id pricebookId = Test.getStandardPricebookId();
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, accs[0].id, 'Bozza');
            orders[0].ProcessType__c = 'Prima Attivazione Fuori delibera';
            orders[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
            orders[0].PrecheckResultSII__c = '';
            orders[0].BillingProfile__c = billings[0].Id;
            orders[0].Pricebook2Id = pricebookId;
            insert orders;
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accs[0].Id);
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1, true, accs[0].id);
    
            List<Case> cases = HDT_UTL_DataFactoryTst.createCase(2, false, accs[0].Id, contacts[0].Id, points[0].id, contracts[0].id, orders[0].id);
            cases[0].DiscardDescription__c = 'zero';
            cases[0].Origin = 'Rifiutologo';
            cases[0].RecordTypeId=constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI;
            cases[1].RecordTypeId=constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI;
            insert cases;
            
            HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) cases[0].Id, billings[0].ContractAccountCode__c);

            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,true);

            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);

            HDT_UTL_DataFactoryTst.createOrderItem(1, true, orders[0].Id, points[0].Id, products[0].id, entries[0].id);
            
            List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', '{"name":"Case","label":"Case","sObjectType":"Case","queryable":true,"fields":[{"name":"AccountId","label":"Account ID"},{"name":"CaseNumber","label":"Case Number"}],"objects":[{"name":"AccountId","label":"Account ID","sObjectType":"Account","relationshipName":"Account","queryable":true,"fields":[{"name":"Name","label":"Account Name"}],"objects":[]}]}', 'Callout_Template.json');
            List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates=HDT_UTL_DataFactoryTst.createCalloutTemplate(1, false, 'Callout_Prova', 'prova', true, 'Case', 'Flat', contentVersionList[0].ContentDocumentId);
            calloutTemplates.addAll(HDT_UTL_DataFactoryTst.createCalloutTemplate(1, false, 'Callout_Prova', 'prova2', true, 'Case', 'Flat', contentVersionList[0].ContentDocumentId));
            insert calloutTemplates;

            id calloutTemplateid = calloutTemplates[0].id;
            
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = contentVersionList[0].ContentDocumentId;
            cDe.LinkedEntityId = calloutTemplateId; 	
            cDe.ShareType = 'V'; 							
            cDe.Visibility = 'AllUsers';
            
            HDT_UTL_DataFactoryTst.createEndpointRule(1,true,'endpname');
            
            HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', 'test', 'test', 'C', 'prova', 'calloutParameters', 'apexCalloutAction');
            HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI, constants.CASE_RECORDTYPE_DEVELOPERNAME_GENERICHE_ATTIVAZIONI, 'A', 'prova2', '', '');
        }
    }

    @isTest 
    public static void testExecuteObjectNull() {		

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        HDT_WS_SegnalazioniTari segnalazione = new HDT_WS_SegnalazioniTari();
        Test.setMock(HttpCalloutMock.class, mock);
    
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c, Phase__c, RecordTypeId, AccountId, NoticeId__c, Origin from Case WHERE DiscardDescription__c = 'zero' LIMIT 1];
        
        wrts_prcgvr__CalloutTemplate__c myTemplate = [Select id, name, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c,
                                                        wrts_prcgvr__IncludeNullFields__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c 
                                                        From wrts_prcgvr__CalloutTemplate__c where wrts_prcgvr__Code__c = 'prova2'];
        
        wrts_prcgvr__PhaseTransition__c myTransition = [Select id, wrts_prcgvr__RecordTypeId__c, wrts_prcgvr__CalloutTemplate__c, wrts_prcgvr__Code__c,
                                                        wrts_prcgvr__DestinationPhase__c, wrts_prcgvr__OriginPhase__c, wrts_prcgvr__Type__c, wrts_prcgvr__RecordTypeName__c
                                                        From wrts_prcgvr__PhaseTransition__c where wrts_prcgvr__CalloutTemplate__c = 'prova2'];
        
        Map<String,String> params = new Map<String,String>();
        params.put('requestType', 'Callout_Template.json');
        
        Map<String,Object> paramsCallOut = new Map<String,Object>();
        paramsCallOut.put('object', myTemplate);
        paramsCallOut.put('multirequest', myOrderItem);   
                        
        Map<String, Object> args=new Map<String, Object>();
        
        args.put('action', myCase);
        args.put('sender', myCase); 
        args.put('wrts_prcgvr__CalloutTemplate__c', 'prova');
        args.put('transition', myTransition);
        args.put('templateMap', paramsCallOut);
        args.put('method', 'TemporaneaNuovaAttivazioneCreaRich');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);
        
        Test.startTest();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)segnalazione.execute(args);

        HDT_WS_SegnalazioniTari.HDT_WRP_SegnalazioniTariResponse res = new HDT_WS_SegnalazioniTari.HDT_WRP_SegnalazioniTariResponse();
        res.status='';
        res.correlationId='';
        res.timestamp='';
        res.errorDetails = null;
        res.data = new HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData();

        HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData res2 = new HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData();
        res2.outcome='';
        res2.errorMessage='errMsg';
        res2.noticeId='ntcId';

        System.assertEquals('OK', responseReturn.message, 'The call was not successful');
        Test.stopTest();
    }

    @isTest
    public static void testExecuteObjectNull2() {

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
		HDT_WS_SegnalazioniTari segnalazione = new HDT_WS_SegnalazioniTari();
        Test.setMock(HttpCalloutMock.class, mock);
            
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c, AccountId, CaseNumber, Phase__c, NoticeId__c, Outcome__c, RecordType.DeveloperName, Origin from case WHERE DiscardDescription__c <> 'zero' LIMIT 1];
        myCase.NoticeId__c = 'fakeid12345';
        myCase.AccountId = null;
        
        wrts_prcgvr__CalloutTemplate__c myTemplate = [Select id, name, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c,
                                                        wrts_prcgvr__IncludeNullFields__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c 
                                                        From wrts_prcgvr__CalloutTemplate__c where wrts_prcgvr__Code__c = 'prova'];
        
        wrts_prcgvr__PhaseTransition__c myTransition = [Select id, wrts_prcgvr__RecordTypeId__c, wrts_prcgvr__CalloutTemplate__c, wrts_prcgvr__Code__c,
                                                        wrts_prcgvr__DestinationPhase__c, wrts_prcgvr__OriginPhase__c, wrts_prcgvr__Type__c, wrts_prcgvr__RecordTypeName__c
                                                        From wrts_prcgvr__PhaseTransition__c where wrts_prcgvr__CalloutTemplate__c = 'prova'];
        
        Map<String,String> params = new Map<String,String>();
        params.put('requestType', 'Callout_Template.json');
        
        Map<String,Object> paramsCallOut = new Map<String,Object>();
        paramsCallOut.put('object', myTemplate);
        paramsCallOut.put('multirequest', myOrderItem);   
                        
        Map<String, Object> args=new Map<String, Object>();
        
        args.put('action', myCase);
        args.put('sender', myCase);
        args.put('wrts_prcgvr__CalloutTemplate__c', 'prova');
        args.put('transition', myTransition);
        args.put('templateMap', paramsCallOut);
        args.put('method', 'TemporaneaNuovaAttivazioneCreaRich');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);

        Test.startTest(); 
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse res = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)segnalazione.execute(args);
        System.assertEquals('OK', res.message, 'The call was not successful');
        Test.stopTest();
    }

    @IsTest
    static void testExecuteException(){
        
        Test.startTest();
        HDT_WS_SegnalazioniTari segnalazione = new HDT_WS_SegnalazioniTari();

        Map<String, Object> args=new Map<String, Object>();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse res = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)segnalazione.execute(args);

        System.assertEquals('KO', res.message, 'There should be an exception running this method');
        Test.stopTest();
        
    }

    @isTest
    public static void testExecuteException2() {

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
		HDT_WS_SegnalazioniTari segnalazione = new HDT_WS_SegnalazioniTari();
        Test.setMock(HttpCalloutMock.class, mock);
            
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Account myAcc = [SELECT Id, CustomerCode__c FROM Account WHERE CustomerCode__c = null LIMIT 1];
        Case myCase = [Select id, DiscardDescription__c, AccountId, CaseNumber, Phase__c, NoticeId__c, Outcome__c, RecordType.DeveloperName, Origin from case WHERE DiscardDescription__c <> 'zero' LIMIT 1];
        myCase.AccountId = myAcc.Id;
        
        wrts_prcgvr__CalloutTemplate__c myTemplate = [Select id, name, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c,
                                                        wrts_prcgvr__IncludeNullFields__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c 
                                                        From wrts_prcgvr__CalloutTemplate__c where wrts_prcgvr__Code__c = 'prova'];
        
        wrts_prcgvr__PhaseTransition__c myTransition = [Select id, wrts_prcgvr__RecordTypeId__c, wrts_prcgvr__CalloutTemplate__c, wrts_prcgvr__Code__c,
                                                        wrts_prcgvr__DestinationPhase__c, wrts_prcgvr__OriginPhase__c, wrts_prcgvr__Type__c, wrts_prcgvr__RecordTypeName__c
                                                        From wrts_prcgvr__PhaseTransition__c where wrts_prcgvr__CalloutTemplate__c = 'prova'];
        
        Map<String,String> params = new Map<String,String>();
        params.put('requestType', 'Callout_Template.json');
        
        Map<String,Object> paramsCallOut = new Map<String,Object>();
        paramsCallOut.put('object', myTemplate);
        paramsCallOut.put('multirequest', myOrderItem);   
                        
        Map<String, Object> args=new Map<String, Object>();
        
        args.put('action', myCase);
        args.put('sender', myCase);
        args.put('wrts_prcgvr__CalloutTemplate__c', 'prova');
        args.put('transition', myTransition);
        args.put('templateMap', paramsCallOut);
        args.put('method', 'TemporaneaNuovaAttivazioneCreaRich');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);

        Test.startTest(); 
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse res = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)segnalazione.execute(args);
        System.assertEquals('KO', res.message, 'The call was not successful');
        Test.stopTest();
    }

    @IsTest
    static void formatEsitoTest(){

        HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData response = new HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData();
        response.outcome = 'outcome';
        response.errorMessage = 'errorMessage';
        response.noticeId = 'noticeId';
		String esito = HDT_WS_SegnalazioniTari.formatEsito(response);
		System.assert(!String.isBlank(esito), 'Unexpected Result');
        
    }
}