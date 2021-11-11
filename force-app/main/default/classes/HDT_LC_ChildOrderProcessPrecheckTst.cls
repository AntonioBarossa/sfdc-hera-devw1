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
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(2,true,'MMS','MMS Azienda','Aziende SME');
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
            points[0].RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO;
            points[0].Account__c = accs[1].id;
            points[0].PlugPresence__c = 'Si';
            points[0].isReseller__c = false;
            points[0].ServicePointCode__c = 'codicepunto';
            points[0].MeterStatus__c = 'Bozza';
            insert points;
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,false,accs[0].id);
            contracts[0].ServicePoint__c = points[0].id;
			insert contracts; 
            
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].id, 'Bozza');
            
            List<Order> orders =  HDT_UTL_DataFactoryTst.createOrder(1, false, accs[0].id, 'Bozza');
            orders[0].ServicePoint__c = points[0].id;
            orders[0].VoltageLevel__c ='MT';
            orders[0].MarketOrigin__c ='Libero';
            orders[0].PowerRequested__c = 50;
            orders[0].PowerCommitted__c = 45;
            orders[0].IsWinback__c = false;
            orders[0].ContractReference__c = contracts[0].id;
            orders[0].SAPImplantCode__c = '';
            insert orders;
            
            List<Order> childOrders =  HDT_UTL_DataFactoryTst.createChildOrder(2, false, accs[0].id, sales, orders[0].id, null);
            childOrders[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
            childOrders[0].ProcessType__c = 'VAS';
            childOrders[0].IncomingCreditCheckResult__c = 'test';
            childOrders[0].OutgoingCreditCheckResult__c = 'test';
            childOrders[0].CreditCheckDescription__c = 'test description';
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

        }
     }
    
    @isTest static void init(){
        
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
                        ServicePoint__r.isReseller__c
                        From Order
                        WHERE Name = 'testOrderName0'];
        
        Test.startTest();
        
        List<HDT_UTL_OrderProcessAssignment.HDT_WRP_Process> processesList = HDT_LC_ChildOrderProcessPrecheck.init(record);
        
        Test.stopTest();
        
        System.assertEquals('Prima Attivazione con modifica', processesList[0].processType, 'init did not work correctly');
        System.assertNotEquals(null, processesList, 'init did not work correctly');
        
    }
    
    @isTest static void next(){
        
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
                        ServicePoint__r.isReseller__c
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
        selectedProcessObject.put('recordType','HDT_RT_Voltura');
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
    
    @isTest static void next2(){
        
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
                         ServicePoint__r.isReseller__c
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
            selectedProcessObject.put('recordType','HDT_RT_Voltura');
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
    
    @isTest static void next3(){
        
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
                     ServicePoint__r.isReseller__c
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
        selectedProcessObject.put('recordType','HDT_RT_Default');
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
    
    @isTest static void next4(){
        
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
                     SupplyCity__c
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
        selectedProcessObject.put('recordType','HDT_RT_VolturaConSwitch');
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
    
    @isTest static void next5(){
        
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
                     ServicePoint__r.isReseller__c
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
        selectedProcessObject.put('recordType','HDT_RT_TemporaneaNuovaAtt');
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
    
    @isTest static void next6(){
        
        Id accId = [Select id from Account LIMIT 1].id;
        
        List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accId);
        activities[0].type__c = 'Gestione Switch in Ripristinatorio';
        activities[0].status__c = 'Creata';
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
                     ServicePoint__r.isReseller__c
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
        selectedProcessObject.put('recordType','HDT_RT_Default');
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
    
    @isTest static void getServicePointTypeFromOrder(){
        
        Order record = [Select id From Order WHERE Name = 'testOrderName0'];
        
        Test.startTest();
        
        String result = HDT_LC_ChildOrderProcessPrecheck.getServicePointTypeFromOrder(record.id);
        
        Test.stopTest();
        
        System.assertEquals('HDT_RT_Ele', result, 'getServicePointTypeFromOrder did not work correctly');
        System.assertNotEquals(null, result, 'getServicePointTypeFromOrder did not work correctly');
        
    }
    
    @isTest static void callDataEnrichment(){
        
        Order newOrder = [Select id From Order WHERE Name = 'testOrderName0'];
            
        Test.setMock(HttpCalloutMock.class, new HDT_WS_ArricchimentoDatiTempMock());
        Test.startTest();
        
        Order result = HDT_LC_ChildOrderProcessPrecheck.callDataEnrichment('', '', newOrder);
        
        Test.stopTest();
        
        System.assertEquals('Imposta Usi Domestici (Cod. G_ICD)', result.ExciseGAS__c, 'callDataEnrichment did not work correctly');
        System.assertNotEquals(null, result, 'callDataEnrichment did not work correctly');
        
    }
    
    @isTest static void checkVasAndCommodity(){
        
        Id orderdId = [Select id From Order WHERE Name = 'testOrderName0'][0].id;
        
        Boolean result = HDT_LC_ChildOrderProcessPrecheck.checkVasAndCommodity(orderdId);
        
        System.assertEquals(true, result, 'checkVasAndCommodity did not work correctly');
        System.assertNotEquals(null, result, 'checkVasAndCommodity did not work correctly');
    }

    @IsTest
    static void testCheckContendibilita(){

        //setup
        Order ord = [SELECT SupplyCityCode__c, SupplyCity__c, MeterSN__c, ServicePointCode__c, OrderNumber, Description, DiscardReason__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];

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
    static void testCheckContendibilitaKo(){

        //setup
        Order ord = [SELECT SupplyCityCode__c, SupplyCity__c, MeterSN__c, ServicePointCode__c, OrderNumber, Description, DiscardReason__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];

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
}