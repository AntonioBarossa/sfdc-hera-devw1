/**
 * Header of the class "HDT_LC_ChildOrderProcessPrecheckTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_ChildOrderProcessPrecheck"
 * @history
 * @Created 07/10/2021
 * Modified By:
 **/

@isTest
public class HDT_LC_ChildOrderProcessPrecheckTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();

            List<Account> accDistr = HDT_UTL_DataFactoryTst.createSimpleAccountDistributore(1,true,'MMS','MMS Azienda','Aziende SME');
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(3,true,'MMS','MMS Azienda','Aziende SME');

            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
            points[0].RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO;
            points[0].Account__c = accs[1].id;
            points[0].PlugPresence__c = 'Si';
            points[0].isReseller__c = false;
            points[0].ServicePointCode__c = 'codicepunto';
            points[0].MeterStatus__c = 'Bozza';
            points[0].SapContractStatus__c = 'Attivo';
            points[0].CommoditySector__c = 'Energia Elettrica';
            points[0].Distributor__c = accDistr[0].Id;
            insert points;
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,false,accs[0].id);
            contracts[0].ServicePoint__c = points[0].id;
			insert contracts; 
            
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].id, 'Bozza');

            List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);

            Id priceBookId = Test.getStandardPriceBookId();

            List<PricebookEntry> stdpriceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, priceBookId);

            List<Pricebook2>pbList=HDT_UTL_DataFactoryTst.createPricebook(1, true);

            List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pbList[0].Id);
            
            List<Order> orders =  HDT_UTL_DataFactoryTst.createOrder(2, false, accs[0].id, 'Bozza');
            orders[0].ServicePoint__c = points[0].id;
            orders[0].VoltageLevel__c ='MT';
            orders[0].MarketOrigin__c ='Libero';
            orders[0].PowerRequested__c = 50;
            orders[0].PowerCommitted__c = 45;
            orders[0].IsWinback__c = false;
            orders[0].ContractReference__c = contracts[0].id;
            orders[0].SAPImplantCode__c = '';
            orders[0].isSTG__c=false;
            orders[0].IsVas__c = false;
            orders[0].VasSubtype__c = '	HERA LED 1 KIT V2';
            orders[0].NumeratorGroup__c = 'ELPVEDM';

            orders[1].ServicePoint__c = points[0].id;
            orders[1].IsVas__c = true;
            orders[1].Pricebook2Id = pbList[0].id;
            insert orders;

            List<OrderItem> ordersItems = HDT_UTL_DataFactoryTst.createOrderItem(1, false, orders[1].id, points[0].id, productList[0].id, priceBookEntryList[0].id);
            ordersItems[0].ConsumptionAnnual__c = 10;
            insert ordersItems;
            
            List<Order> childOrders =  HDT_UTL_DataFactoryTst.createChildOrder(2, false, accs[0].id, sales, orders[0].id, null);
            childOrders[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
            childOrders[0].ProcessType__c = 'VAS';
            childOrders[0].IncomingCreditCheckResult__c = 'test';
            childOrders[0].OutgoingCreditCheckResult__c = 'test';
            childOrders[0].CreditCheckDescription__c = 'test description';
            childOrders[0].VasSubtype__c = 'Analisi consumi';
            childOrders[0].isSTG__c=false;
            insert childOrders;
            
            List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].id, null, null, 'Quote');
            quotes[0].AllowChangeUse__c = false;
            quotes[0].AmendmentAllowed__c = false;
            insert quotes;
            
            List<BillingProfile__c> billings = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accs[0].id);
            
            List<ServiceRequest__c> requests = HDT_UTL_DataFactoryTst.createServiceRequest(1, false);
            requests[0].ServicePointCode__c = 'ServicePointCode__c';
            requests[0].Status__c = 'Bozza';
            requests[0].Order__c = orders[0].id;
            requests[0].CommoditySector__c = 'Acqua';
            requests[0].Type__c = 'Order';
            requests[0].ServicePoint__c = points[0].id;
            requests[0].ProcessType__c = 'Alert';
            requests[0].BillingProfile__c = billings[0].id;
            requests[0].Account__c = accs[0].id;
            insert requests;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, false, accs[2].id);
            contacts[0].Company__c = 'MMS';
            insert contacts;
            
            HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accs[0].id, contacts[0].id);

            ProcessMatrix__c processObj = new ProcessMatrix__c();
            processObj.Name = 'test1';
            processObj.Commodity__c = '	Energia Elettrica';
            processObj.ContractStatus__c = 'Attivo';
            processObj.CasualCode__c = '';
            //processObj.CreatedById = '';
            processObj.ExistActivityDatiDiscordanti__c = false;
            processObj.ExistActivitySwitchRipristinatorio__c = false;
            processObj.IsAmendment__c = false;
            processObj.IsChangeUse__c = false;
            processObj.isOwnAccount__c = 'No';
            processObj.IsReseller__c = false;
            processObj.IsSameAccount__c = false;
            processObj.isSTG__c = false;
            processObj.OngoingSwitchOut__c = false;
            //processObj.OwnerId = '';
            processObj.PlugPresence__c = true;
            processObj.PowerChange__c = true;
            processObj.ProcessName__c = 'Prima Attivazione con modifica';
            processObj.RecordTypeName__c = 'HDT_RT_TemporaneaNuovaAtt';
            processObj.marketOrigin__c='Libero';

            List<ProcessMatrix__c> allProcess = new List<ProcessMatrix__c>();
            allProcess.add(processObj);
            insert allProcess;
           
        }
     }
    
    @isTest 
    static void init(){
        
        Order record = [Select id,
                        ServicePoint__c,
                        VoltageLevel__c,
                        AccountId,
                        MarketOrigin__c,
                        PowerRequested__c,
                        PowerCommitted__c,
                        IsWinback__c,
                        ServicePoint__r.MeterStatus__c,
                        ServicePoint__r.Account__c,
                        ServicePoint__r.PlugPresence__c,
                        ServicePoint__r.ServicePointCode__c,
                        ServicePoint__r.RecordType.DeveloperName,
                        SBQQ__Quote__r.AllowChangeUse__c,
                        SBQQ__Quote__r.AmendmentAllowed__c, 
                        ServicePoint__r.isReseller__c,
                        IsVas__c,
                        VasSubtype__c,
                        ServicePoint__r.SapContractStatus__c,
                        ServicePoint__r.CommoditySector__c,
                        isSTG__c
                        From Order
                        WHERE Name = 'testOrderName0'];
        
        Test.startTest();
        
        //List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process> processesList = HDT_LC_ChildOrderProcessPrecheck.init(record);
        List<ProcessMatrix__c> processesList = HDT_LC_ChildOrderProcessPrecheck.init(record);
        
        Test.stopTest();

        System.assertEquals('Prima Attivazione con modifica', processesList[0].processName__c, 'init did not work correctly');
        System.assertNotEquals(null, processesList, 'init did not work correctly');
        
    }
    
    @isTest 
    static void next(){
        
        Order ord = [Select id,
                        ServicePoint__c,
                        VoltageLevel__c,
                        MarketOrigin__c,
                        PowerRequested__c,
                        PowerCommitted__c,
                        IsWinback__c,
                        SAPImplantCode__c,
                        ServicePoint__r.MeterStatus__c,
                        ServicePoint__r.Account__c,
                        ServicePoint__r.PlugPresence__c,
                        ServicePoint__r.ServicePointCode__c,
                        ServicePoint__r.RecordType.DeveloperName,
                        SBQQ__Quote__r.AllowChangeUse__c,
                        SBQQ__Quote__r.AmendmentAllowed__c, 
                        ServicePoint__r.isReseller__c,
                        CommodityFormula__c,
                        SupplyCity__c,
                     	AccountId,
                     	Account.RecordType.DeveloperName,
                        SupplyType__c
                        From Order
                        WHERE Name = 'testOrderName0'];
        
        ServiceRequest__c srRequest = [Select id,
                                           ServicePointCode__c,
                                           Status__c,
                                           Order__c,
                                           CommoditySector__c,
                                           Type__c,
                                           ServicePoint__c,
                                           ProcessType__c
                                       From ServiceRequest__c];
        
        Map<String,String> selectedProcessObject = new Map<String,String>();
        selectedProcessObject.put('RecordTypeName__c','HDT_RT_Voltura');
        selectedProcessObject.put('processType','Prima Attivazione');
        selectedProcessObject.put('processCode','somecode');
        Map<String,String> extraParams = new Map<String,String>();
        extraParams.put('servicePointType','HDT_RT_Gas');

		String deliberate = 'dontknow';
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.next(ord,ord.id,selectedProcessObject,deliberate,extraParams,srRequest);
        
        Test.stopTest();
        
        System.assertEquals('', result, 'next did not work correctly');
        System.assertNotEquals(null, result, 'next did not work correctly');
        
    }
    
    @isTest 
    static void next2(){
        
            Order ord = [Select id,
                         ServicePoint__c,
                         VoltageLevel__c,
                         AccountId,
                         MarketOrigin__c,
                         PowerRequested__c,
                         PowerCommitted__c,
                         IsWinback__c,
                         SAPImplantCode__c,
                         ServicePoint__r.MeterStatus__c,
                         ServicePoint__r.Account__c,
                         ServicePoint__r.PlugPresence__c,
                         ServicePoint__r.ServicePointCode__c,
                         ServicePoint__r.RecordType.DeveloperName,
                         SBQQ__Quote__r.AllowChangeUse__c,
                         SBQQ__Quote__r.AmendmentAllowed__c, 
                         ServicePoint__r.isReseller__c,
                         CommodityFormula__c,
                     	 Account.RecordType.DeveloperName,
                         SupplyCity__c,
                         SupplyType__c                          
                         From Order
                         WHERE Name = 'testOrderName0'];
            
            ServiceRequest__c srRequest = [Select id,
                                           ServicePointCode__c,
                                           Status__c,
                                           Order__c,
                                           CommoditySector__c,
                                           Type__c,
                                           ServicePoint__c,
                                           ProcessType__c,
                                           Account__c,
                                           BillingProfile__c
                                           From ServiceRequest__c];
            srRequest.ServicePoint__c = null;
            
            Map<String,String> selectedProcessObject = new Map<String,String>();
            selectedProcessObject.put('RecordTypeName__c','HDT_RT_Voltura');
            selectedProcessObject.put('processType','Prima Attivazione');
            selectedProcessObject.put('processCode','somecode');
            Map<String,String> extraParams = new Map<String,String>();
            extraParams.put('servicePointType','HDT_RT_Gas');
            
            String deliberate = 'dontknow';
            
            Test.startTest();
            
            String result = HDT_LC_ChildOrderProcessPrecheck.next(ord,ord.id,selectedProcessObject,deliberate,extraParams,srRequest);
            
            Test.stopTest();
            
            System.assertEquals('', result, 'next did not work correctly');
            System.assertNotEquals(null, result, 'next did not work correctly');
            
        }
    
    @isTest 
    static void next3(){
        
        Order ord = [Select id,
                     ServicePoint__c,
                     VoltageLevel__c,
                     AccountId,
                     MarketOrigin__c,
                     PowerRequested__c,
                     PowerCommitted__c,
                     IsWinback__c,
                     SAPImplantCode__c,
                     ServicePoint__r.MeterStatus__c,
                     ServicePoint__r.Account__c,
                     ServicePoint__r.PlugPresence__c,
                     ServicePoint__r.ServicePointCode__c,
                     ServicePoint__r.RecordType.DeveloperName,
                     SBQQ__Quote__r.AllowChangeUse__c,
                     SBQQ__Quote__r.AmendmentAllowed__c, 
                     ServicePoint__r.isReseller__c,
                     Account.RecordType.DeveloperName,
                     CommodityFormula__c,
                     SupplyType__c
                     From Order
                     WHERE Name = 'testOrderName0'];
            
        ServiceRequest__c srRequest = [Select id,
                                       ServicePointCode__c,
                                       Status__c,
                                       Order__c,
                                       CommoditySector__c,
                                       Type__c,
                                       ServicePoint__c,
                                       ProcessType__c,
                                       Account__c,
                                       BillingProfile__c
                                       From ServiceRequest__c];
        srRequest.ServicePoint__c = null;
        
        Map<String,String> selectedProcessObject = new Map<String,String>();
        selectedProcessObject.put('RecordTypeName__c','HDT_RT_Default');
        selectedProcessObject.put('processType','Prima Attivazione');
        selectedProcessObject.put('processCode','somecode');
        Map<String,String> extraParams = new Map<String,String>();
        extraParams.put('servicePointType','HDT_RT_Gas');
        
        String deliberate = 'dontknow';
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.next(ord,ord.id,selectedProcessObject,deliberate,extraParams,srRequest);
        
        Test.stopTest();
        
        System.assertEquals('', result, 'next did not work correctly');
        System.assertNotEquals(null, result, 'next did not work correctly');
    }
    
    @isTest 
    static void next4(){
        
        Order ord = [Select id,
                     ServicePoint__c,
                     VoltageLevel__c,
                     AccountId,
                     MarketOrigin__c,
                     PowerRequested__c,
                     PowerCommitted__c,
                     IsWinback__c,
                     SAPImplantCode__c,
                     ServicePoint__r.MeterStatus__c,
                     ServicePoint__r.Account__c,
                     ServicePoint__r.PlugPresence__c,
                     ServicePoint__r.ServicePointCode__c,
                     ServicePoint__r.RecordType.DeveloperName,
                     SBQQ__Quote__r.AllowChangeUse__c,
                     SBQQ__Quote__r.AmendmentAllowed__c, 
                     ServicePoint__r.isReseller__c,
                     CommodityFormula__c,
                     SupplyCity__c,
                     Account.RecordType.DeveloperName,
                     SupplyType__c
                     From Order
                     WHERE Name = 'testOrderName0'];
            
        ServiceRequest__c srRequest = [Select id,
                                       ServicePointCode__c,
                                       Status__c,
                                       Order__c,
                                       CommoditySector__c,
                                       Type__c,
                                       ServicePoint__c,
                                       ProcessType__c,
                                       Account__c,
                                       BillingProfile__c
                                       From ServiceRequest__c];
        srRequest.ServicePoint__c = null;
        
        Map<String,String> selectedProcessObject = new Map<String,String>();
        selectedProcessObject.put('RecordTypeName__c','HDT_RT_VolturaConSwitch');
        selectedProcessObject.put('processType','Prima Attivazione');
        selectedProcessObject.put('processCode','somecode');
        Map<String,String> extraParams = new Map<String,String>();
        extraParams.put('servicePointType','HDT_RT_Gas');
        
        String deliberate = 'dontknow';
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.next(ord,ord.id,selectedProcessObject,deliberate,extraParams,srRequest);
        
        Test.stopTest();
        
        System.assertEquals('', result, 'next did not work correctly');
        System.assertNotEquals(null, result, 'next did not work correctly');
    }
    
    @isTest 
    static void next5(){
        
        Order ord = [Select id,
                     ServicePoint__c,
                     VoltageLevel__c,
                     AccountId,
                     MarketOrigin__c,
                     PowerRequested__c,
                     PowerCommitted__c,
                     IsWinback__c,
                     SAPImplantCode__c,
                     ServicePoint__r.MeterStatus__c,
                     ServicePoint__r.Account__c,
                     ServicePoint__r.PlugPresence__c,
                     ServicePoint__r.ServicePointCode__c,
                     ServicePoint__r.RecordType.DeveloperName,
                     SBQQ__Quote__r.AllowChangeUse__c,
                     SBQQ__Quote__r.AmendmentAllowed__c, 
                     ServicePoint__r.isReseller__c,
                     Account.RecordType.DeveloperName,
                     CommodityFormula__c,
                     SupplyType__c
                     From Order
                     WHERE Name = 'testOrderName0'];
            
        ServiceRequest__c srRequest = [Select id,
                                       ServicePointCode__c,
                                       Status__c,
                                       Order__c,
                                       CommoditySector__c,
                                       Type__c,
                                       ServicePoint__c,
                                       ProcessType__c,
                                       Account__c,
                                       BillingProfile__c
                                       From ServiceRequest__c];
        srRequest.ServicePoint__c = null;
       
        Map<String,String> selectedProcessObject = new Map<String,String>();
        selectedProcessObject.put('RecordTypeName__c','HDT_RT_TemporaneaNuovaAtt');
        selectedProcessObject.put('processType','Prima Attivazione');
        selectedProcessObject.put('processCode','somecode');
        Map<String,String> extraParams = new Map<String,String>();
        extraParams.put('servicePointType','HDT_RT_Gas');
        
        String deliberate = 'dontknow';
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.next(ord,ord.id,selectedProcessObject,deliberate,extraParams,srRequest);
        
        Test.stopTest();
        
        System.assertEquals('', result, 'next did not work correctly');
        System.assertNotEquals(null, result, 'next did not work correctly');
    }
    
    @isTest 
    static void next6(){
        
        Id accId = [Select id from Account LIMIT 1].id;
        
        List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
        activities[0].type__c = 'Gestione Switch in Ripristinatorio';
        activities[0].wrts_prcgvr__Status__c = 'Creata';
        activities[0].Account__c = accId;
        activities[0].ServicePointCode__c = 'codicepunto';
        insert activities;
        
        Order ord = [Select id,
                     ServicePoint__c,
                     VoltageLevel__c,
                     AccountId,
                     MarketOrigin__c,
                     PowerRequested__c,
                     PowerCommitted__c,
                     IsWinback__c,
                     SAPImplantCode__c,
                     ServicePoint__r.MeterStatus__c,
                     ServicePoint__r.Account__c,
                     ServicePoint__r.PlugPresence__c,
                     ServicePoint__r.ServicePointCode__c,
                     ServicePoint__r.RecordType.DeveloperName,
                     SBQQ__Quote__r.AllowChangeUse__c,
                     SBQQ__Quote__r.AmendmentAllowed__c, 
                     ServicePoint__r.isReseller__c,
                     Account.RecordType.DeveloperName,
                     CommodityFormula__c,
                     SupplyType__c
                     From Order
                     WHERE Name = 'testOrderName0'];
            
        ServiceRequest__c srRequest = [Select id,
                                       ServicePointCode__c,
                                       Status__c,
                                       Order__c,
                                       CommoditySector__c,
                                       Type__c,
                                       ServicePoint__c,
                                       ProcessType__c,
                                       Account__c,
                                       BillingProfile__c
                                       From ServiceRequest__c];
        srRequest.ServicePoint__c = null;
       
        Map<String,String> selectedProcessObject = new Map<String,String>();
        selectedProcessObject.put('RecordTypeName__c','HDT_RT_Default');
        selectedProcessObject.put('processType','Switch in Ripristinatorio');
        selectedProcessObject.put('processCode','somecode');
        Map<String,String> extraParams = new Map<String,String>();
        extraParams.put('servicePointType','HDT_RT_Gas');
        
        String deliberate = 'dontknow';
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.next(ord,ord.id,selectedProcessObject,deliberate,extraParams,srRequest);
        
        Test.stopTest();
        
        System.assertEquals('', result, 'next did not work correctly');
        System.assertNotEquals(null, result, 'next did not work correctly');
    }
    
    @isTest 
    static void getServicePointTypeFromOrder(){
        
        Order record = [Select id From Order WHERE Name = 'testOrderName0'];
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.getServicePointTypeFromOrder(record.id);
        
        Test.stopTest();
        
        System.assertEquals('HDT_RT_Ele', result, 'getServicePointTypeFromOrder did not work correctly');
        System.assertNotEquals(null, result, 'getServicePointTypeFromOrder did not work correctly');
        
    }
    
    @isTest 
    static void callDataEnrichmentException(){
        
        Order newOrder = [Select id From Order WHERE Name = 'testOrderName0'];
        
        String result;

        Test.setMock(HttpCalloutMock.class, new HDT_WS_ArricchimentoDatiTempMock());
        Test.startTest();
        
        HDT_LC_ChildOrderProcessPrecheck.callDataEnrichment('', '', JSON.serialize(newOrder));
        
        Test.stopTest();
        

        System.assertNotEquals('', result, 'callDataEnrichment did not work correctly');
        
    }
    
    @isTest 
    static void checkVasAndCommodity(){
        
        Order myOrder = [SELECT id, OrderReferenceNumber, ContractReference__c, VasSubtype__c, RecordType.DeveloperName FROM Order WHERE RecordType.DeveloperName = 'HDT_RT_VAS' LIMIT 1][0];

        Boolean result = HDT_LC_ChildOrderProcessPrecheck.checkVasAndCommodity(myOrder, myOrder.RecordType.DeveloperName); 
        
        System.assertEquals(true, result, 'checkVasAndCommodity did not work correctly');
        System.assertNotEquals(null, result, 'checkVasAndCommodity did not work correctly');
    }

    @IsTest
    static void testCheckContendibilita(){

        //setup
        Order ord = [SELECT SupplyCityCode__c, SupplyCity__c, MeterSN__c, ServicePointCode__c, OrderNumber, Description, DiscardReason__c, SalesCompanyCode__c, DistributorCode__c, CommodityFormula__c,DistributorFormula__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];
        List<HDT_LocalDispatcherInrete__mdt> metaCont = [SELECT DeveloperName, MasterLabel, Label, QualifiedApiName, DispatcherCode__c, DispatcherDesc__c FROM HDT_LocalDispatcherInrete__mdt];

        //mock webservice call
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"code":null,"description":null,"objects":[{"fields":[{"fieldType":"TEXT","name":"ANNOTAZIONI","value":"PROVA_NEW_FLOW"},{"fieldType":"TEXT","name":"result","value":"OK"},{"fieldType":"TEXT","name":"requestId","value":""},{"fieldType":"TEXT","name":"errorMessage","value":""},{"fieldType":"TEXT","name":"rifRich","value":"00002349"},{"fieldType":"TEXT","name":"RECORD_ID","value":""},{"fieldType":"TEXT","name":"FASE","value":"Esito OK da DL"},{"fieldType":"TEXT","name":"DES_ERR_AEEG","value":"001"}],"id":null,"name":null,"objectType":null,"objects":null}]}]}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_QservHandlerMock(res));

        //start test
        Test.startTest();

        Map<String, Object> resultMap = HDT_LC_ChildOrderProcessPrecheck.checkContendibilita(ord);
        
        //assertions
        System.assertEquals(true , resultMap.get('ESITO'), 'Esito != true');
        System.assertEquals('001' , resultMap.get('DES_ERR_AEEG'), 'DES_ERR_AEEG != 001');

        Test.stopTest();
        
    }

    @IsTest
    static void testCheckContendibilitaErrorFromHeroku(){

        //setup
        Order ord = [SELECT DistributorFormula__c,SupplyCityCode__c, SupplyCity__c, MeterSN__c, ServicePointCode__c, OrderNumber, Description, DiscardReason__c, SalesCompanyCode__c, DistributorCode__c, CommodityFormula__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];

        //mock webservice call
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"code":null,"description":null,"objects":[{"fields":[{"fieldType":"TEXT","name":"errorMessage","value":"ERRORE"}],"id":null,"name":null,"objectType":null,"objects":null}]}]}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_QservHandlerMock(res));

        //start test
        Test.startTest();

        Map<String, Object> resultMap = HDT_LC_ChildOrderProcessPrecheck.checkContendibilita(ord);

        //assertions
        System.assertEquals(false , resultMap.get('ESITO'), 'Esito != false');
        System.assertEquals('ERRORE' , resultMap.get('DES_ERR_AEEG'), 'DES_ERR_AEEG != ERRORE');

        Test.stopTest();
        
    }

    static void testCheckContendibilitaErrorBypassFromHeroku(){

        //setup
        Order ord = [SELECT DistributorFormula__c,SupplyCityCode__c, SupplyCity__c, MeterSN__c, ServicePointCode__c, OrderNumber, Description, DiscardReason__c, SalesCompanyCode__c, DistributorCode__c, CommodityFormula__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];

        //mock webservice call
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"code":null,"description":null,"objects":[{"fields":[{"fieldType":"TEXT","name":"errorMessage","value":"venditore"}],"id":null,"name":null,"objectType":null,"objects":null}]}]}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_QservHandlerMock(res));

        //start test
        Test.startTest();

        Map<String, Object> resultMap = HDT_LC_ChildOrderProcessPrecheck.checkContendibilita(ord);

        //assertions
        System.assertEquals(true , resultMap.get('ESITO'), 'Esito != true');
        System.assertEquals('venditore' , resultMap.get('DES_ERR_AEEG'), 'DES_ERR_AEEG != venditore');

        Test.stopTest();
        
    }

    @IsTest
    static void testCheckContendibilitaKo(){

        //setup
        Order ord = [SELECT SupplyCityCode__c, SupplyCity__c, MeterSN__c, ServicePointCode__c, OrderNumber, Description, DiscardReason__c, SalesCompanyCode__c, DistributorCode__c, CommodityFormula__c, DistributorFormula__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];

        //mock webservice call
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"code":null,"description":null,"objects":[{"fields":[{"fieldType":"TEXT","name":"ANNOTAZIONI","value":"PROVA_NEW_FLOW"},{"fieldType":"TEXT","name":"result","value":"OK"},{"fieldType":"TEXT","name":"requestId","value":""},{"fieldType":"TEXT","name":"errorMessage","value":""},{"fieldType":"TEXT","name":"rifRich","value":"00002349"},{"fieldType":"TEXT","name":"RECORD_ID","value":""},{"fieldType":"TEXT","name":"FASE","value":"Esito KO da DL"},{"fieldType":"TEXT","name":"DES_ERR_AEEG","value":"001"}],"id":null,"name":null,"objectType":null,"objects":null}]}]}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_QservHandlerMock(res));

        //start test
        Test.startTest();

        Map<String, Object> resultMap = HDT_LC_ChildOrderProcessPrecheck.checkContendibilita(ord);

        //assertions
        System.assertEquals(false , resultMap.get('ESITO'), 'Esito != false');

        Test.stopTest();
        
    }

    @IsTest
    static void testCheckContendibilitaError(){
        
        //mock webservice call
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"code":null,"description":null,"objects":[{"fields":[{"fieldType":"TEXT","name":"ANNOTAZIONI","value":"PROVA_NEW_FLOW"},{"fieldType":"TEXT","name":"result","value":"OK"},{"fieldType":"TEXT","name":"requestId","value":""},{"fieldType":"TEXT","name":"errorMessage","value":""},{"fieldType":"TEXT","name":"rifRich","value":"00002349"},{"fieldType":"TEXT","name":"RECORD_ID","value":""},{"fieldType":"TEXT","name":"FASE","value":"Esito KO da DL"},{"fieldType":"TEXT","name":"DES_ERR_AEEG","value":"001"}],"id":null,"name":null,"objectType":null,"objects":null}]}]}');
        res.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_QservHandlerMock(res));

        //start test
        Test.startTest();

        try {

            Map<String, Object> resultMap = HDT_LC_ChildOrderProcessPrecheck.checkContendibilita(null);
                
        } catch (Exception e) {
            //assert
            System.assertNotEquals(null, e.getMessage(), 'Expected exception');
        }

        Test.stopTest();
        
    }

    
    @IsTest
    static void testgetConsumptionAnnualForVas(){

        Order ord = [SELECT id, IsVAS__c, Pricebook2Id FROM Order WHERE Name = 'testOrderName1' LIMIT 1];

        Test.startTest();

        try{
            String getConsumAnForVas = HDT_LC_ChildOrderProcessPrecheck.getConsumptionAnnualForVas(ord.id);
            System.assertEquals('10.00', getConsumAnForVas, 'getConsumptionAnnualForVas did not work correctly');

        } catch (Exception e) {

            System.assertNotEquals(null, e.getMessage(), 'Expected exception');
        }

        Test.stopTest();

    }

    @IsTest

    static void testEffectiveDateBonus(){

        Order ord = [SELECT id, NumeratorGroup__c FROM Order WHERE Name = 'testOrderName0' LIMIT 1];

        Test.startTest();

        Date effectiveDate = HDT_LC_ChildOrderProcessPrecheck.getEffectiveDateBonus(ord.id);
        Date dateToCompare = (System.today().addMonths(1)).toStartOfMonth();

        Test.stopTest();

        System.assertEquals(dateToCompare, effectiveDate, 'getEffectiveDateBonus did not work correctly');
    }

    @isTest 
    static void next7(){
        
        Order ord = [Select id,
                     ServicePoint__c,
                     VoltageLevel__c,
                     AccountId,
                     MarketOrigin__c,
                     PowerRequested__c,
                     PowerCommitted__c,
                     IsWinback__c,
                     SAPImplantCode__c,
                     ServicePoint__r.MeterStatus__c,
                     ServicePoint__r.Account__c,
                     ServicePoint__r.PlugPresence__c,
                     ServicePoint__r.ServicePointCode__c,
                     ServicePoint__r.RecordType.DeveloperName,
                     SBQQ__Quote__r.AllowChangeUse__c,
                     SBQQ__Quote__r.AmendmentAllowed__c, 
                     ServicePoint__r.isReseller__c,
                     Account.RecordType.DeveloperName,
                     CommodityFormula__c,
                     SupplyType__c
                     From Order
                     WHERE Name = 'testOrderName0'];
            
        ServiceRequest__c srRequest = [Select id,
                                       ServicePointCode__c,
                                       Status__c,
                                       Order__c,
                                       CommoditySector__c,
                                       Type__c,
                                       ServicePoint__c,
                                       ProcessType__c,
                                       Account__c,
                                       BillingProfile__c
                                       From ServiceRequest__c];

        srRequest.ServicePoint__c = null;
       
        Map<String,String> selectedProcessObject = new Map<String,String>();
        selectedProcessObject.put('RecordTypeName__c','HDT_RT_SwitchIn');
        selectedProcessObject.put('processType','Prima Attivazione');
        selectedProcessObject.put('processCode','somecode');
        Map<String,String> extraParams = new Map<String,String>();
        extraParams.put('servicePointType','HDT_RT_Gas');
        
        String deliberate = 'dontknow';
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.next(ord,ord.id,selectedProcessObject,deliberate,extraParams,srRequest);
        
        Test.stopTest();
        
        System.assertEquals('', result, 'next did not work correctly');
        System.assertNotEquals(null, result, 'next did not work correctly');
    }

    @isTest
    static void getProcessDriverTst()
    {
        Order ord = [Select id,
                        ServicePoint__c,
                        VoltageLevel__c,
                        MarketOrigin__c,
                        PowerRequested__c,
                        PowerCommitted__c,
                        IsWinback__c,
                        SAPImplantCode__c,
                        ServicePoint__r.MeterStatus__c,
                        ServicePoint__r.Account__c,
                        ServicePoint__r.PlugPresence__c,
                        ServicePoint__r.ServicePointCode__c,
                        ServicePoint__r.RecordType.DeveloperName,
                        SBQQ__Quote__r.AllowChangeUse__c,
                        SBQQ__Quote__r.AmendmentAllowed__c, 
                        ServicePoint__r.isReseller__c,
                        CommodityFormula__c,
                        SupplyCity__c,
                     	AccountId,
                     	Account.RecordType.DeveloperName,
                        SupplyType__c
                        From Order
                        WHERE Name = 'testOrderName0'];
        Test.startTest();
            String resultOne = HDT_LC_ChildOrderProcessPrecheck.getProcessDriver(ord);
            String resultTwo = HDT_LC_ChildOrderProcessPrecheck.getProcessDriver(null);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(resultOne), 'Driver Non Calcolati');
        System.assertEquals(true, !String.isNotBlank(resultTwo), 'Errore non gestito correttamente');

    }
    
}