/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 04/08/2021
* @description HDT_QR_OrderItem Test Class
* @history Lucas da Silva Fernandes – 04/08/2021 – Created Class
*/

@isTest
public with sharing class HDT_QR_OrderItemTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickInstance();
        
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Opportunity> opp = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, acc[0].Id, 'Bozza');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, sales[0].Id);
        orders[0].Phase__c = 'Bozza';
        
        insert orders;
        
        List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, true, orders[0].Id, opp[0].Id, sales[0].Id, 'Amendment');
        
        orders[0].SBQQ__Quote__c = quotes[0].Id;
        update orders;
        
        List<Product2> prod = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        prod[0].Name = 'PDR';
        prod[0].Family = 'VAS Opzione prodotto';
        
        insert prod;
        
        Id pricebookId=Test.getStandardPricebookId();
        
        List<PricebookEntry> pbEntry = HDT_UTL_DataFactoryTst.createPricebookEntry(prod, true, pricebookId);
        
        orders[0].Pricebook2Id = pricebookId;
        update orders;
        
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        
        List<BillingProfile__c> bp =  HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        
        List<OrderItem> oiList = HDT_UTL_DataFactoryTst.createOrderItem(1, false, orders[0].Id, spList[0].Id, prod[0].Id, pbEntry[0].Id);
        oiList[0].BillingProfile__c = bp[0].Id;
        insert oiList;
        
    }
    
    @isTest
    public static void testGetRecordsByOrderIdListFilteredPdrPod() {
        
        Test.startTest();
        
        Id orderId = [SELECT Id FROM Order WHERE Order.Phase__c = 'Bozza'].Id;
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(orderId);
        
        List<OrderItem> oiList = new List<OrderItem>();
        
        HDT_QR_OrderItem qrOi = new HDT_QR_OrderItem();
        
        oiList = qrOi.getRecordsByOrderIdListFilteredPdrPod(orderIds);
        
        System.assertEquals(orderId, oiList[0].OrderId, 'Order IDs match.');
        System.assertNotEquals(orderId, null, 'Order IDs mismatch.');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testGetRecordsByOrderIdFilteredPdrPod() {
        
        Test.startTest();
        
        String orderId = String.valueOf([SELECT Id FROM Order WHERE Order.Phase__c = 'Bozza'].Id);
        
        List<OrderItem> oiList = new List<OrderItem>();
        
        System.debug('Order IDs: '+ orderId);
        
        HDT_QR_OrderItem qrOi = new HDT_QR_OrderItem();
        
        oiList = qrOi.getRecordsByOrderIdFilteredPdrPod(orderId);
        
        System.debug('oiList: '+ oiList);
        
        System.assertEquals(orderId, String.valueOf(oiList[0].OrderId), 'Order IDs match.');
        System.assertNotEquals(orderId, null, 'Order IDs mismatch.');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testGetRecordsWithBillingProfile() {
        
        Test.startTest();
        
        Id orderId = [SELECT Id FROM Order].Id;
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(orderId);
        
        List<OrderItem> oiList = new List<OrderItem>();
        
        HDT_QR_OrderItem qrOi = new HDT_QR_OrderItem();
        
        oiList = qrOi.getRecordsWithBillingProfile(orderIds);
        
        System.assertEquals(orderId, oiList[0].OrderId, 'Order IDs match.');
        System.assertNotEquals(orderId, null, 'Order IDs mismatch.');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testGetRecordsWithAmend() {
        
        Test.startTest();
        
        Id orderId = [SELECT Id FROM Order].Id;
        
        System.debug('orderId: '+orderId);
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(orderId);
        
        List<OrderItem> oiList = new List<OrderItem>();
        
        HDT_QR_OrderItem qrOi = new HDT_QR_OrderItem();
        
        oiList = qrOi.getRecordsWithAmend(orderIds);
        
        System.debug('oiList: '+oiList);
        
        System.assertEquals(orderId, oiList[0].OrderId, 'Order IDs match.');
        System.assertNotEquals(orderId, null, 'Order IDs mismatch.');
        
        Test.stopTest();
    }
    
    // @isTest
    // public static void testGetMainItem() {
        
    //     Test.startTest();
        
    //     String orderId = String.valueOf([SELECT Id FROM Order].Id);
        
    //     List<OrderItem> oiList = new List<OrderItem>();
        
    //     System.debug('Order IDs: '+ orderId);
        
    //     HDT_QR_OrderItem qrOi = new HDT_QR_OrderItem();
        
    //     oiList = qrOi.getMainItem(orderId);
        
    //     System.debug('oiList: '+ oiList);
        
    //     System.assertEquals(orderId, String.valueOf(oiList[0].OrderId), 'Order IDs match.');
    //     System.assertNotEquals(orderId, null, 'Order IDs mismatch.');
        
    //     Test.stopTest();
    // }
    
    @isTest
    public static void testGetAnalisiConsumi() {
        
        Test.startTest();
        
        Product2 prod = [SELECT Id, Name, Family FROM Product2];
        prod.Family = 'VAS Fatturabili';
        update prod;
        
        List<Order> orderList = [SELECT Id FROM Order LIMIT 1];
        HDT_QR_OrderItem qrOi = new HDT_QR_OrderItem();
        List<OrderItem> oiList = qrOi.getAnalisiConsumi(orderList[0].Id);
        
        System.assertEquals(orderList[0].Id, String.valueOf(oiList[0].OrderId), 'Order IDs match.');
        System.assertNotEquals(orderList[0].Id, null, 'Order IDs mismatch.');
        
        Test.stopTest();
    }
    @isTest
    public static void testGetRecordsByOrderIdFilteredFamilyBonus() {
        
        
        
        Test.startTest();
        
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(orderId);
        
        List<OrderItem> oiList = new List<OrderItem>();
        
        HDT_QR_OrderItem qrOi = new HDT_QR_OrderItem();
        
        oiList = qrOi.getRecordsByOrderIdFilteredFamilyBonus(orderIds);
        
        
        System.assertNotEquals(orderId, null, 'Order IDs mismatch.');
        
        Test.stopTest();
    }
    
    
    
    
    @isTest
    public static void testGetItemFromOrderIdList() {
        
        
        
        Test.startTest();
        
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        
        List<Id> orderIds = new List<Id>();
        orderIds.add(orderId);
        
        List<OrderItem> oiList = new List<OrderItem>();
        
        oiList = HDT_QR_OrderItem.getItemFromOrderIdList(orderIds);
        
        
        System.assertNotEquals(oiList[0].OrderId, null, 'Order IDs mismatch.');
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void testGetPodOrderFromQuote() {
        
        
        Test.startTest();
        List<OrderItem> qrOi = new List<OrderItem>();
        qrOi = [
            SELECT
            OrderId,
            Order.SBQQ__Quote__c,
            Order.ServicePoint__r.ServicePointCode__c,
            Order.ServicePoint__c
            FROM
            OrderItem LIMIT 1];
        
        
        List<OrderItem> oiList = new List<OrderItem>();
        HDT_QR_OrderItem qrOi1 = new HDT_QR_OrderItem();
        oiList = qrOi1.getPodOrderFromQuote(qrOi[0].Order.SBQQ__Quote__c,qrOi[0].Order.ServicePoint__c);
        System.debug('@@@'+qrOi[0].Order.ServicePoint__c);
        

        
        Test.stopTest();
    }
}