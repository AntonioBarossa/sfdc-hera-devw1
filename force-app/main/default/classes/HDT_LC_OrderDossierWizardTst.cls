/**
* @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
* @date 07/07/2021
* @description HDT_LC_OrderDossierWizard Test Class
* @history Lucas da Silva Fernandes – 07/07/2021 – Class Created 
*/

@isTest
public with sharing class HDT_LC_OrderDossierWizardTst {
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        List<Opportunity> opportunities = HDT_UTL_DataFactoryTst.createOpportunity(1, true);

        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');
        sales.add(HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id,'Attiva')[0]);

        List<ServicePoint__c> servicePoints = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        
        List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        products[0].Family = 'VAS Opzione prodotto';
        products[0].Name = 'POD';
        insert products;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pricebookEntry = HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebookId);

        List<BillingProfile__c> billingProfiles = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);

        List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(2,false, accounts[0].Id, sales, pricebookId);
        orders[0].BillingProfile__c = billingProfiles[0].Id;
        orders[1].BillingProfile__c = billingProfiles[0].Id;

        insert orders;

        List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, true, orders[0].Id, opportunities[0].Id, sales[0].Id, 'Amendment');

        opportunities[0].SBQQ__PrimaryQuote__c = quotes[0].Id;

        update opportunities;

        orders[0].SBQQ__Quote__c = quotes[0].Id;
        orders[1].SBQQ__Quote__c = quotes[0].Id;

        update orders;

        List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(2, false, orders[0].Id, servicePoints[0].Id, products[0].Id, pricebookEntry[0].Id);
        orderItems.addAll(HDT_UTL_DataFactoryTst.createOrderItem(2, false, orders[1].Id, servicePoints[0].Id, products[0].Id, pricebookEntry[0].Id));

        for (OrderItem ordIt : orderItems) {

            ordIt.BillingProfile__c = billingProfiles[0].Id;
            
        }

        insert orderItems;

        List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);

        HDT_UTL_DataFactoryTst.createChildOrder(1, true, accounts[0].Id, sales, orders[0].Id, contacts[0].Id);

    }

    @isTest
    public static void testControllerInit() {

        Test.startTest();

        Sale__c saleAttiva = [SELECT Id, Status__c, Account__c, Name FROM Sale__c WHERE Name LIKE 'testSaleName%' and Status__c = 'Attiva' LIMIT 1];
        System.debug(saleAttiva);

        Sale__c saleBozza = [SELECT Id, Status__c, Account__c, Name FROM Sale__c WHERE Name LIKE 'testSaleName%' and Status__c = 'Bozza' LIMIT 1];

        Map<String, Object> mapAttiva = HDT_LC_OrderDossierWizard.controllerInit(saleAttiva.Id);

        HDT_LC_OrderDossierWizard.controllerInit(saleBozza.Id);

        System.assertEquals(6, mapAttiva.size(), 'controllerInit did not work correctly');

        System.assertNotEquals(0, mapAttiva.size(), 'controllerInit did not work correctly');

        Test.stopTest();
    }

    @isTest
    public static void testGetOrderParent() {

        Test.startTest();

        Order testOrder = [SELECT Id FROM Order WHERE Name Like 'testOrderName%' LIMIT 1];
        Order parentOrder = HDT_LC_OrderDossierWizard.getOrderParent(testOrder.Id);

        System.assertEquals('testOrderName0', parentOrder.Name, 'getOrderParent did not work correctly');

        System.assertNotEquals('', parentOrder.Name, 'getOrderParent did not work correctly');

        Test.stopTest();
    }

    @isTest
    public static void testcheckCommunityLogin() {

        Test.startTest();

        Boolean check = HDT_LC_OrderDossierWizard.checkCommunityLogin();

        System.assertEquals(false, check, 'checkCommunityLogin did not work correctly');

        System.assertNotEquals(true, check, 'checkCommunityLogin did not work correctly');

        Test.stopTest();
    }

    @isTest
    public static void testsaveProsegui() {

        Test.startTest();

        Order testOrder = [SELECT Id FROM Order WHERE Name Like 'testOrderName%' LIMIT 1];

        Boolean check = HDT_LC_OrderDossierWizard.saveProsegui(testOrder.Id);

        System.assertEquals(false, check, 'saveProsegui did not work correctly');

        System.assertNotEquals(true, check, 'saveProsegui did not work correctly');

        Test.stopTest();
    }
}