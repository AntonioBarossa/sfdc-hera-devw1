/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 12-15-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_WS_AgevolazioneTst{
    
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			wrts_prcgvr.InstallIntegration.install();
			wrts_prcgvr.VersionManager.newClassInstance('CalloutTemplateMng');
			wrts_prcgvr.VersionManager.newClassInstance('EndpointRulesIntegration');
            wrts_prcgvr.VersionManager.newClassInstance('CalloutClient');
            
            HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickCasePhase();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();
            
			List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            
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
    
			List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, false, accs[0].id, contacts[0].Id, points[0].id, contracts[0].id, null);
            cases[0].DiscardDescription__c = 'zero';
            cases[0].Order__c = orders[0].id;
            cases[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
            insert cases;
            
			HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) cases[0].Id, billings[0].ContractAccountCode__c);

			List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,true);

            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);

			HDT_UTL_DataFactoryTst.createOrderItem(1, true, orders[0].Id, points[0].Id, products[0].id, entries[0].id);
            
			List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', '{"name":"Order","label":"Order","sObjectType":"Order","queryable":true,"fields":[{"name":"AccountId","label":"Account ID"},{"name":"OrderNumber","label":"Order Number"}],"objects":[{"name":"AccountId","label":"Account ID","sObjectType":"Account","relationshipName":"Account","queryable":true,"fields":[{"name":"Name","label":"Account Name"}],"objects":[]}]}', 'Callout_Template.json');
			List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates=HDT_UTL_DataFactoryTst.createCalloutTemplate(1, true, 'Callout_Prova', 'prova', true, 'Order', 'Flat', contentVersionList[0].ContentDocumentId);
            id calloutTemplateid = calloutTemplates[0].id;
            
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = contentVersionList[0].ContentDocumentId;
            cDe.LinkedEntityId = calloutTemplateId; 	
            cDe.ShareType = 'V'; 							
            cDe.Visibility = 'AllUsers';
            
            HDT_UTL_DataFactoryTst.createEndpointRule(1,true,'endpname');
            
            String rtName = 'HDT_RT_Segnalazioni';
            String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();

            HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','prova', 'calloutParameters', 'apexCalloutAction');

            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('MulesoftHergoPath', 'Callout:MulesoftHergoPath/notice', 'POST', 'testUser');
		}
	}


    @isTest 
    public static void testExecuteObjectOk() {		

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        HDT_WS_Agevolazione agevolazione = new HDT_WS_Agevolazione();
        Test.setMock(HttpCalloutMock.class, mock);
    
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c, CommercialProduct__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];

        wrts_prcgvr__CalloutTemplate__c myTemplate = [Select id, name, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c,
                                                        wrts_prcgvr__IncludeNullFields__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c 
                                                        From wrts_prcgvr__CalloutTemplate__c];
        
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
        args.put('sender', myOrder);
        args.put('wrts_prcgvr__CalloutTemplate__c', 'prova');
        args.put('transition', myTransition);
        args.put('templateMap', paramsCallOut);
        args.put('method', 'TemporaneaNuovaAttivazioneCreaRich');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);
        
        Test.startTest();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)agevolazione.execute(args);

        HDT_WS_Agevolazione.HDT_WS_AgevolazioneResponse res = new  HDT_WS_Agevolazione.HDT_WS_AgevolazioneResponse();
        res.status='';
        res.correlationId='';
        res.timestamp='';
        res.data = new HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData();

        System.assertEquals('OK', responseReturn.message, 'The call was not successful');
        Test.stopTest();
    }

    @isTest
    public static void testException() {		

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        HDT_WS_Agevolazione agevolazione = new HDT_WS_Agevolazione();
        Test.setMock(HttpCalloutMock.class, mock);
    
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c, CommercialProduct__c FROM Order];
        myOrder.CommercialProduct__c = 'Istruttoria DL116';
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];

        wrts_prcgvr__CalloutTemplate__c myTemplate = [Select id, name, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c,
                                                        wrts_prcgvr__IncludeNullFields__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c 
                                                        From wrts_prcgvr__CalloutTemplate__c];
        
        wrts_prcgvr__PhaseTransition__c myTransition = [Select id, wrts_prcgvr__RecordTypeId__c, wrts_prcgvr__CalloutTemplate__c, wrts_prcgvr__Code__c,
                                                        wrts_prcgvr__DestinationPhase__c, wrts_prcgvr__OriginPhase__c, wrts_prcgvr__Type__c, wrts_prcgvr__RecordTypeName__c
                                                        From wrts_prcgvr__PhaseTransition__c where wrts_prcgvr__CalloutTemplate__c = 'prova'];
        
        Map<String,String> params = new Map<String,String>();
        params.put('requestType', 'Callout_Template.json');
        
        Map<String,Object> paramsCallOut = new Map<String,Object>();
        paramsCallOut.put('object', myTemplate);
        paramsCallOut.put('multirequest', myOrderItem);   
                        
        Map<String, Object> args=new Map<String, Object>();

        myCase.Order__c = null;
        update myCase;
        
        args.put('action', myCase);
        args.put('sender', myOrder);
        args.put('wrts_prcgvr__CalloutTemplate__c', 'prova');
        args.put('transition', myTransition);
        args.put('templateMap', paramsCallOut);
        args.put('method', 'TemporaneaNuovaAttivazioneCreaRich');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);
        
        Test.startTest();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)agevolazione.execute(args);

        HDT_WS_Agevolazione.HDT_WS_AgevolazioneResponse res = new  HDT_WS_Agevolazione.HDT_WS_AgevolazioneResponse();
        res.status='';
        res.correlationId='';
        res.timestamp='';
        res.data = new HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData();

        System.assertEquals('KO', responseReturn.message, 'The call was unexpectedly Success');
        Test.stopTest();
    }

    @isTest
    public static void testIstruttoria() {		

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        HDT_WS_Agevolazione agevolazione = new HDT_WS_Agevolazione();
        Test.setMock(HttpCalloutMock.class, mock);
    
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c, CommercialProduct__c FROM Order];
        myOrder.CommercialProduct__c = 'Istruttoria DL116';
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];

        wrts_prcgvr__CalloutTemplate__c myTemplate = [Select id, name, wrts_prcgvr__Code__c, wrts_prcgvr__ConfigurationFile__c,
                                                        wrts_prcgvr__IncludeNullFields__c, wrts_prcgvr__ObjectType__c, wrts_prcgvr__Structure__c 
                                                        From wrts_prcgvr__CalloutTemplate__c];
        
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
        args.put('sender', myOrder);
        args.put('wrts_prcgvr__CalloutTemplate__c', 'prova');
        args.put('transition', myTransition);
        args.put('templateMap', paramsCallOut);
        args.put('method', 'TemporaneaNuovaAttivazioneCreaRich');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);
        
        Test.startTest();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)agevolazione.execute(args);

        HDT_WS_Agevolazione.HDT_WS_AgevolazioneResponse res = new  HDT_WS_Agevolazione.HDT_WS_AgevolazioneResponse();
        res.status='';
        res.correlationId='';
        res.timestamp='';
        res.data = new HDT_WS_SegnalazioniTari.HDT_WRP_ResponseData();

        System.assertEquals('KO', responseReturn.message, 'The call was unexpectedly Success');
        Test.stopTest();
    }

}