/**
* @author 'Keltin Mesonjesi' (keltin.mesonjesi@protonmail.ch);
* @date 19/04/2020
* @description Class HDT_UTL_ContractProcess.cls
* @history Lucas da Silva Fernandes – 19/04/2020 – Updated Header
*/

@isTest
public with sharing class HDT_UTL_ContractProcessTst {
    
   
    static void setup1(){
        
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> cttList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        // List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        // List<Pricebook2> pricebookList = HDT_UTL_DataFactoryTst.createPricebook(2, true);
        // List<PricebookEntry> pEList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, false, pricebookList[1].Id, pricebookList[0].Id);

        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        Id priceBookId = Test.getStandardPriceBookId();
        List<PricebookEntry> stdpriceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, priceBookId);
        List<Pricebook2> pbList = HDT_UTL_DataFactoryTst.createPricebook(1, true);
        List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pbList[0].Id);
        
        productList[0].Family = 'Offerta commerciale';
        update productList;

        cttList[0].SBQQ__Order__c = orderList[0].Id;
        cttList[0].ServicePoint__c = spList[0].Id;
        cttList[0].Status = 'Attivo';
        insert cttList;   
        
        
        orderList[0].BillingProfile__c = bpList[0].Id;
        orderList[0].ServicePoint__c = spList[0].Id;
        orderList[0].ContractReference__c = cttList[0].Id;
        orderList[0].Pricebook2Id = pbList[0].Id;
        insert orderList;

        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Contract__c = cttList[0].Id;
        sub.SBQQ__Quantity__c = 10;

        insert sub;

        OrderItem ordItem = new OrderItem();
        ordItem.OrderId = orderList[0].Id;
        ordItem.Product2Id = productList[0].Id;
        ordItem.UnitPrice = 1000;
        ordItem.Quantity = 10;
        ordItem.PricebookEntryId = priceBookEntryList[0].Id;
        insert ordItem;
        
        
        
        
    }
    
    static void setup2(){
        
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        orderList[0].BillingProfile__c = bpList[0].Id;
        orderList[0].ServicePoint__c = spList[0].Id;
        insert orderList;

        List<Contract> cttList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
        cttList[0].SBQQ__Order__c = orderList[0].Id;
        cttList[0].Status = 'Attivo';
        insert cttList;
        
        
        
    }
    
    @isTest
    public static void testOrderCompletataPhaseManagement() {
        
        Test.startTest();
        setup2();
        List<Contract> cttList = [SELECT Id, SBQQ__Order__c, BillingProfile__c FROM Contract WHERE SAPContractCode__c='3011913470' LIMIT 1];
        System.debug('cttList: '+cttList);
        List<Order> orderList = [SELECT Id, BillingProfile__c FROM Order WHERE Name = 'testOrderName0' LIMIT 1];
        System.debug('orderList: '+orderList);
        HDT_UTL_ContractProcess.orderCompletataPhaseManagement(cttList);
        System.debug('cttList: '+cttList);
        System.assertEquals(orderList[0].Id, cttList[0].SBQQ__Order__c, 'Order Id Match');
        System.assertNotEquals(null, cttList[0].SBQQ__Order__c, 'Order Id mismatch');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testmoveOut() {
        
        Test.startTest();
        setup1();
        List<Contract> cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];
        List<Order> orderList = [SELECT Id FROM Order LIMIT 1];
        
        orderList[0].ContractReference__c = cttList[0].Id;
        
        update orderList;
        
        HDT_UTL_ContractProcess.moveOut( orderList[0].Id, 'ContractReference__c' );
        
        cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];
        
        System.assertEquals(cttList[0].Status, 'Cessato','Status non in Cessato');
        System.assertEquals(cttList[0].EndDate, date.Today(), 'Data non aggiornata ad Oggi correttamente');
        
        Test.stopTest();
    }

    @isTest
    public static void testmoveOutSp() {
        
        Test.startTest();
        setup1();
        List<Contract> cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];
        List<Order> orderList = [SELECT Id, ServicePoint__c FROM Order LIMIT 1];
        
        HDT_UTL_ContractProcess.moveOutFromServicePoint( orderList[0].ServicePoint__c );
        
        cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];
        
        System.assertEquals(cttList[0].Status, 'Cessato','Status non in Cessato');
        System.assertEquals(cttList[0].EndDate, date.Today(), 'Data non aggiornata ad Oggi correttamente');
        
        Test.stopTest();
    }

    @isTest
    public static void testMoveOutNoContrat()
    {   setup2();
        Test.startTest();
            List<Contract> cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];
            List<Order> orderList = [SELECT Id FROM Order LIMIT 1];

            HDT_UTL_ContractProcess.moveOut( orderList[0].Id, 'ContractReference__c' );
        Test.stopTest();
        cttList = [SELECT Id,Status,EndDate FROM Contract LIMIT 1];
        System.assertEquals('Attivo', cttList[0].Status, 'Contratto aggiornato erroneamente');
    }


    @isTest
    public static void testHandleMassiveContractCreationVAS() {
        
        Test.startTest();
        setup1();
        List<Order> orderList = [SELECT Id, ServicePoint__c FROM Order LIMIT 1];
        List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
        
        orderList[0].ProcessType__c = 'VAS';
        orderList[0].ServicePoint__c = servicePointList[0].Id;
        orderList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VAS').getRecordTypeId();
        
        update orderList;
        
        HDT_UTL_ContractProcess.handleMassiveContractCreation( orderList[0].Id);
        
        // System.assertEquals(true, 'Cessato','Status non in Cessato');
        // System.assertEquals(true, date.Today(), 'Data non aggiornata ad Oggi correttamente');
        
        Test.stopTest();
    }

    @isTest
    public static void testHandleMassiveContractCreationScontiBonus() {
        
        Test.startTest();
        setup1();
        List<Order> orderList = [SELECT Id, ServicePoint__c FROM Order LIMIT 1];
        List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
        
        orderList[0].ProcessType__c = 'Aggiunta Sconti o Bonus VAS';
        orderList[0].ServicePoint__c = servicePointList[0].Id;
        orderList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_ScontiBonus').getRecordTypeId();
        
        update orderList;
        
        HDT_UTL_ContractProcess.handleMassiveContractCreation( orderList[0].Id);
        
        // System.assertEquals(true, 'Cessato','Status non in Cessato');
        // System.assertEquals(true, date.Today(), 'Data non aggiornata ad Oggi correttamente');
        
        Test.stopTest();
    }

    @isTest
    public static void testHandleMassiveContractCreationNoVAS() {
        
        Test.startTest();
        setup1();
        List<Order> orderList = [SELECT Id, ServicePoint__c FROM Order LIMIT 1];
        List<ServicePoint__c> servicePointList = [SELECT Id FROM ServicePoint__c LIMIT 1];
        
        orderList[0].ProcessType__c = 'Voltura';
        orderList[0].ServicePoint__c = servicePointList[0].Id;
        orderList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Voltura').getRecordTypeId();
        
        update orderList;
        
        HDT_UTL_ContractProcess.handleMassiveContractCreation( orderList[0].Id);
        
        // System.assertEquals(true, 'Cessato','Status non in Cessato');
        // System.assertEquals(true, date.Today(), 'Data non aggiornata ad Oggi correttamente');
        
        Test.stopTest();
    }
    
}