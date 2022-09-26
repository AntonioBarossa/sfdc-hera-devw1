/**
 * Header of the class "HDT_WS_SalesApexCalloutActionTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_SalesApexCalloutAction"
 * @history
 * @Created 19/10/2021
 * Modified By:
 **/
@isTest
public with sharing class HDT_WS_SalesApexCalloutActionTst{
    
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
    
			List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, false, accs[0].id, contacts[0].Id, points[0].id, contracts[0].id, orders[0].id);
            cases[0].DiscardDescription__c = 'zero';
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
            
            HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', '0121X000001RmAWQA0', 'HDT_RT_Disattivazioni', 'C', 'prova', 'calloutParameters', 'apexCalloutAction');
		}
	}
    
    @isTest public static void testExecuteObjectNull(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '12';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, TecnicalPhase__c FROM Order]; 
        
        System.assertEquals('Comunicazione verso Heroku KO', myOrder.TecnicalPhase__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }

	@isTest public static void testExecuteAnnullamento(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
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
        args.put('method', 'Annullamento');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, TecnicalPhase__c FROM Order]; 
        
        System.assertEquals('Annullamento - Comunicazione verso Heroku OK', myOrder.TecnicalPhase__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }

	@isTest public static void testExecuteAmmissibilitaKO(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c,  VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, TecnicalPhase__c FROM Order]; 
        
        System.assertEquals('Annullato', myOrder.TecnicalPhase__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }

	@isTest public static void testExecuteAmmissibilitaOK(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = 'one';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, TecnicalPhase__c FROM Order]; 
        
        System.assertEquals('Annullato', myOrder.TecnicalPhase__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteEsitoKOdaDL(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '2';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest(); 
        
        myOrder = [SELECT Id, CausalCode__c FROM Order]; 
        
        System.assertEquals('testflusso', myOrder.CausalCode__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteEsitoOKdaDL(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '3';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, CausalCode__c FROM Order]; 
        
        System.assertEquals('testflusso', myOrder.CausalCode__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteAmmPrecheckKOSII(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '4';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();      
        
        myOrder = [SELECT Id, CausalCode__c FROM Order]; 
        
        System.assertEquals('034', myOrder.CausalCode__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteAmmPrecheckOKSII(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '5';
        update myCase;
        
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
        //args.put('sender', myCase);
        args.put('wrts_prcgvr__CalloutTemplate__c', 'prova');
        args.put('transition', myTransition);
        args.put('templateMap', paramsCallOut);
        args.put('method', 'TemporaneaNuovaAttivazioneCreaRich');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, PrecheckResultSII__c FROM Order]; 
        
        System.assertEquals('OK', myOrder.PrecheckResultSII__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteEsitoKOdaSII(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '6';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, CausalCode__c FROM Order]; 
        
        System.assertEquals('testflusso', myOrder.CausalCode__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteEsitoOKdaSII(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '7';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest(); 
        
        myOrder = [SELECT Id, CausalCode__c FROM Order]; 
        
        System.assertEquals('testflusso', myOrder.CausalCode__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteErroreLavorazioneSAP(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '8';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest();
        
        myOrder = [SELECT Id, DiscardReason__c FROM Order]; 
        
        System.assertEquals('testnote', myOrder.DiscardReason__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteCompletata(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '9';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest(); 

        myOrder = [SELECT Id, ContractAccountCode__c FROM Order]; 
        
        System.assertEquals('something', myOrder.ContractAccountCode__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteFaseNulla(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '10';
        update myCase;
        
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
        args.put('method', 'Annullamento');
        args.put('parameters', params);
        args.put('multirequest', myOrderItem);
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest(); 
        
        myOrder = [SELECT Id, TecnicalPhase__c FROM Order]; 
        
        System.assertEquals('Annullamento - Comunicazione verso Heroku OK', myOrder.TecnicalPhase__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteFaseNullaRecordId(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, RecordTypeId, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '10';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest(); 
        
        myOrder = [SELECT Id, TecnicalPhase__c FROM Order]; 
        
        System.assertEquals('Comunicazione verso Heroku OK', myOrder.TecnicalPhase__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }
    
    @isTest public static void testExecuteResult(){		
        
        Order myOrder = [SELECT Id, Name, BillingProfile__c, VASType__c, PrecheckResultSII__c, ProcessType__c, Phase__c, AccountId, ServicePoint__c,CommercialProduct__c,CommercialProductCode__c,CommodityFormula__c FROM Order];
        
        OrderItem myOrderItem = [SELECT Id FROM OrderItem];
        
        Case myCase = [Select id, DiscardDescription__c from case];
        myCase.DiscardDescription__c = '11';
        update myCase;
        
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
        
        HDT_WS_SalesApexCalloutAction.mock = new HDT_WS_SalesApexCalloutActionMock();
        Test.startTest();
        
        HDT_WS_SalesApexCalloutAction salesApexCallOut = new HDT_WS_SalesApexCalloutAction();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)salesApexCallOut.execute(args);
        
        Test.stopTest(); 
        
        myOrder = [SELECT Id, TecnicalPhase__c FROM Order]; 
        
        System.assertEquals('Comunicazione verso Heroku KO', myOrder.TecnicalPhase__c, 'HDT_WS_SalesApexCalloutAction did not work correctly');
        System.assertNotEquals(null,  responseReturn, 'HDT_WS_SalesApexCalloutAction did not work correctly');
    }

    @isTest
    public static void testpopulateCommercialProductCodeFromContract(){
        wrts_prcgvr.MRR_1_0.MultiRequest request = (wrts_prcgvr.MRR_1_0.MultiRequest)JSON.deserialize('{"requests":[{"objects":[{"name":"Order","label":"Order","sObjectType":"Order","queryable":true,"fields":[{"name":"AccountId","value":"Account ID"},{"name":"OrderNumber","value":"Order Number"}]}]}]}',wrts_prcgvr.MRR_1_0.MultiRequest.class);
        Order ord = [SELECT id,ServicePoint__c,ContractReference__c, ParentOrder__c FROM Order LIMIT 1];
        Contract contr = [SELECT id FROM Contract LIMIT 1];
        Product2 prod = [SELECT id FROM Product2 LIMIT 1];
        prod.Family = 'Offerta commerciale';
        prod.Version__c = 'V2';
        prod.ProductCode = 'TEST';
        update prod;
        SBQQ__Subscription__c sub = HDT_UTL_DataFactoryTst.createSubscription (1, false, null, contr.Id, null)[0];
        sub.SBQQ__Product__c = prod.Id;
        insert sub;
        Test.startTest();
            ord.ContractReference__c = contr.id;
            ord.ServicePoint__c = null;
            ord.ParentOrder__c = null;
            new HDT_WS_SalesApexCalloutAction().populateCommercialProductCode(ord,request);
            system.assertEquals(true, checkRequest(request), 'La request non è stata popolata correttamente');
        Test.stopTest();
    }

    @isTest
    public static void testpopulateCommercialProductCodeFromServicePoint(){
        wrts_prcgvr.MRR_1_0.MultiRequest request = (wrts_prcgvr.MRR_1_0.MultiRequest)JSON.deserialize('{"requests":[{"objects":[{"name":"Order","label":"Order","sObjectType":"Order","queryable":true,"fields":[{"name":"OFFERTA","value":"WRONG_VALUE"},{"name":"PROFILO","value":"WRONG_VALUE"}]}]}]}',wrts_prcgvr.MRR_1_0.MultiRequest.class);
        Order ord = [SELECT id,AccountId FROM Order LIMIT 1];
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, ord.AccountId, 'Bozza');
        orders[0].Name = 'ParentOrder';
        insert orders;
        ServicePoint__c sp = [SELECT id FROM ServicePoint__c LIMIT 1];
        ord.ServicePoint__c = sp.Id;
        ord.ParentOrder__c = orders[0].Id;
        update ord;
        Product2 prod = [SELECT id FROM Product2 LIMIT 1];
        prod.Family = 'Offerta commerciale';
        prod.Version__c = 'V2';
        prod.ProductCode = 'TEST';
        update prod;
        PricebookEntry pe = [SELECT id FROM PricebookEntry LIMIT 1];
        HDT_UTL_DataFactoryTst.createOrderItem(1, true, ord.Id, sp.Id, prod.Id, pe.Id);
        ord = [SELECT id,ServicePoint__c,ContractReference__c, ParentOrder__c FROM Order LIMIT 1];
        Test.startTest();
            new HDT_WS_SalesApexCalloutAction().populateCommercialProductCode(ord,request);
            system.assertEquals(true, checkRequest(request), 'La request non è stata popolata correttamente');
        Test.stopTest();
    }

    private static Boolean checkRequest(wrts_prcgvr.MRR_1_0.MultiRequest mrrList){
        Boolean response = true;
        for(wrts_prcgvr.MRR_1_0.WObject obj : mrrList.requests[0].objects){
            if(obj.objectType!= null && obj.objectType.equalsIgnoreCase('Order')){
                for(wrts_prcgvr.MRR_1_0.Field f : obj.fields){
                    if(f.name.equalsIgnoreCase('OFFERTA') && !'TEST'.equalsIgnoreCase(f.value)){
                        response = false;   
                    }else if (f.name.equalsIgnoreCase('PROFILO')&&!'V2'.equalsIgnoreCase(f.value)){
                        response = false;
                    }
                }
            }
        }
        return response;
    }

}