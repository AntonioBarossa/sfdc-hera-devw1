@IsTest
public with sharing class HDT_WS_CreditCheckNotifyTest {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Credit Check KO','Bozza',constants.ORDER_RECORDTYPEID_SUBENTRO,constants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);

        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(2,false,'MMS','MMS Azienda','Aziende SME');
        insert accs;
        List<Contact> conts = HDT_UTL_DataFactoryTst.createContact(1, false, accs[0].Id);
        conts[0].Company__c='MMS';
        insert conts;
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
        points[0].RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_GAS;
        points[0].Account__c = accs[1].id;
        points[0].PlugPresence__c = 'Si';
        points[0].isReseller__c = false;
        points[0].ServicePointCode__c = 'codicepunto';
        points[0].MeterStatus__c = 'Bozza';
        points[0].AnnualConsumption__c =500;
        points[0].CommoditySector__c = 'Gas';
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

        List<Order> childOrders =  HDT_UTL_DataFactoryTst.createChildOrder(1, false, accs[0].id, sales, orders[0].id, null);
        childOrders[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro').getRecordTypeId();
        childOrders[0].ServicePoint__c = points[0].id;
        childOrders[0].ProcessType__c = 'Subentro Gas';
        childOrders[0].Contact__c = conts[0].Id;
        insert childOrders;

    }

    @isTest
    public static void testEmptyCrmId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/CreditCheckNotify';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"crmId" : "","errorCode" : "008","creditCheckDescription" : "TEST_DESCRIPTION","outgoingCreditCheckResult" : "","incomingCreditCheckResult" : ""}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_CreditCheckNotify.doPost();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode, 'Errato Status Code quando crmid è vuoto');
    }

    @isTest
    public static void testRecordNotFound() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/CreditCheckNotify';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"crmId" : "01p3O000005AGfI","errorCode" : "008","creditCheckDescription" : "TEST_DESCRIPTION","outgoingCreditCheckResult" : "","incomingCreditCheckResult" : ""}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_CreditCheckNotify.doPost();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode, 'Errato Status Code quando il crmId non restituisce ordini');
    }

    @isTest
    public static void testWorkedErrorCode() {
        Order ord = [SELECT id FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/CreditCheckNotify';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"crmId" : "'+String.valueOf(ord.Id).substring(0,15)+'","errorCode" : "008","creditCheckDescription" : "TEST_DESCRIPTION","outgoingCreditCheckResult" : "","incomingCreditCheckResult" : "KO"}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_CreditCheckNotify.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Errato Status code quando il codice errore è già gestito');
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Type__c = 'KO Credit Check' AND Order__c = :ord.Id];
        System.assertEquals(true, activities.isEmpty(), 'Si è creata una activity nonostante il codice errore fosse tra quelli già gestiti.');
    }

    @isTest
    public static void testIncomingKo() {
        Order ord = [SELECT id FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/CreditCheckNotify';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"crmId" : "'+String.valueOf(ord.Id).substring(0,15)+'","errorCode" : "XXX","creditCheckDescription" : "TEST_DESCRIPTION","outgoingCreditCheckResult" : "","incomingCreditCheckResult" : "KO"}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_CreditCheckNotify.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Errato Status code incoming KO');
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Type__c = 'KO Credit Check' AND Order__c = :ord.Id];
        System.assertEquals(true, activities.size()==1, 'Non Si è creata una activity di KO credit check');
        ord = [SELECT id,OutgoingCreditCheckResult__c,IncomingCreditCheckResult__c,CreditCheckDescription__c FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        System.assertEquals(true, 'KO'.equalsIgnoreCase(ord.IncomingCreditCheckResult__c) && 'TEST_DESCRIPTION'.equalsIgnoreCase(ord.CreditCheckDescription__c), 'Ordine non aggiornato correttamente');
    }

    @isTest
    public static void testOutgoingKo() {
        Order ord = [SELECT id FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/CreditCheckNotify';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"crmId" : "'+String.valueOf(ord.Id).substring(0,15)+'","errorCode" : "","creditCheckDescription" : "TEST_DESCRIPTION","outgoingCreditCheckResult" : "KO","incomingCreditCheckResult" : ""}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_CreditCheckNotify.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Errato Status code outgoing KO');
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Type__c = 'KO Precedente Cliente' AND Order__c = :ord.Id];
        System.assertEquals(true, activities.size()==1, 'Non Si è creata una activity di KO Precedente Cliente');
        ord = [SELECT id,OutgoingCreditCheckResult__c,IncomingCreditCheckResult__c,CreditCheckDescription__c FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        System.assertEquals(true, 'KO'.equalsIgnoreCase(ord.OutgoingCreditCheckResult__c) && 'TEST_DESCRIPTION'.equalsIgnoreCase(ord.CreditCheckDescription__c), 'Ordine non aggiornato correttamente');
    }

    @isTest
    public static void testIncomingOk() {
        Order ord = [SELECT id FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/CreditCheckNotify';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"crmId" : "'+String.valueOf(ord.Id).substring(0,15)+'","errorCode" : "","creditCheckDescription" : "TEST_DESCRIPTION","outgoingCreditCheckResult" : "","incomingCreditCheckResult" : "OK"}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_CreditCheckNotify.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Errato Status code outgoing KO');
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Type__c = 'KO Credit Check' AND Order__c = :ord.Id];
        System.assertEquals(true, activities.isEmpty(), 'Si è creata una activity di KO Credit Check');
        ord = [SELECT id,OutgoingCreditCheckResult__c,IncomingCreditCheckResult__c,CreditCheckDescription__c FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        System.assertEquals(true, 'OK'.equalsIgnoreCase(ord.IncomingCreditCheckResult__c) && 'TEST_DESCRIPTION'.equalsIgnoreCase(ord.CreditCheckDescription__c), 'Ordine non aggiornato correttamente');
    }

    @isTest
    public static void testOutgoingOk() {
        Order ord = [SELECT id FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/CreditCheckNotify';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"crmId" : "'+String.valueOf(ord.Id).substring(0,15)+'","errorCode" : "","creditCheckDescription" : "TEST_DESCRIPTION","outgoingCreditCheckResult" : "OK","incomingCreditCheckResult" : ""}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            HDT_WS_CreditCheckNotify.doPost();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Errato Status code outgoing KO');
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Type__c = 'KO Precedente Cliente' AND Order__c = :ord.Id];
        System.assertEquals(true, activities.isEmpty(), 'Si è creata una activity di KO Precedente Cliente');
        ord = [SELECT id,OutgoingCreditCheckResult__c,IncomingCreditCheckResult__c,CreditCheckDescription__c FROM Order WHERE ProcessType__c = 'Subentro Gas' LIMIT 1];
        System.assertEquals(true, 'OK'.equalsIgnoreCase(ord.OutgoingCreditCheckResult__c) && 'TEST_DESCRIPTION'.equalsIgnoreCase(ord.CreditCheckDescription__c), 'Ordine non aggiornato correttamente');
    }
}