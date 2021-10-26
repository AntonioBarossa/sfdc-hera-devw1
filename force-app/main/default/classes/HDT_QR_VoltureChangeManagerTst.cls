/** @frpanico 12/10/2021
 * Test Class for the class HDT_QR_VoltureChangeManager
 */
@IsTest
public with sharing class HDT_QR_VoltureChangeManagerTst {
    
    private static HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        //Create 1 order one for the parent and one for the child 1
        //Create 2 OrderItems (to test loop with more than one item)
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);  
        spList[0].CommoditySector__c = 'Energia Elettrica';
        update spList;
		
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<Order> childOrderList = HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, saleList, orderList[0].Id, contactList[0].Id);
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        List<Pricebook2> priceBookList = HDT_UTL_DataFactoryTst.createPricebook(1, true);
        Id priceBookId = Test.getStandardPriceBookId();
        PricebookEntry pbEntry = new PriceBookEntry(Pricebook2Id = priceBookId, Product2Id = productList[0].Id, UnitPrice = 10000, IsActive = true);
        insert pbEntry;
        List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, priceBookList[0].Id);
        childOrderList[0].Pricebook2Id = priceBookList[0].Id;
        childOrderList[0].ProcessType__c = 'Switch in Ele';
        update childOrderList;
        orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(2, true, childOrderList[0].Id, spList[0].Id,productList[0].Id,priceBookEntryList[0].Id);

        List<wrts_prcgvr__ActivityTemplate__c> activitiesTemplate = new List<wrts_prcgvr__ActivityTemplate__c>();
        activitiesTemplate = HDT_UTL_DataFactoryTst.createActivityTemplate(1,true);
    }

    @IsTest
    static void getOrderItemByOrderIdTst()
    {
        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c 
        FROM Order WHERE ParentOrder__c != null];
        Test.startTest();
        List<OrderItem> orderItemList = voltureChangeQr.getOrderItemByOrderId(orderList[0].Id);
        Test.stopTest();
        
        System.assertEquals(1, orderList.size(),'Order non trovato');
        System.assertEquals(2, orderItemList.size(),'OrderItmes non trovati');
    }

    @IsTest
    static void getAccountInfoByIdTst()
    {
        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c 
        FROM Order WHERE ParentOrder__c != null];
        Test.startTest();
        List<Account> accountList = voltureChangeQr.getAccountInfoById(orderList[0].AccountId);
        Test.stopTest();
        System.assertEquals(1, accountList.size(),'Account non trovato');
    }

    @IsTest
    static void getActivityTemplateByNameTst()
    {
        List<wrts_prcgvr__ActivityTemplate__c> activityTemplate = [SELECT Name FROM wrts_prcgvr__ActivityTemplate__c];
        Test.startTest();
        List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = voltureChangeQr.getActivityTemplateByName(activityTemplate[0].Name);
        Test.stopTest();
        System.assertEquals(1, activityTemplates.size(),'Activity Template non trovato');
    }

    @IsTest
    static void getExciseTranscodeTst()
    {
        Test.startTest();
        List<HDT_ExciseTranscode__mdt> results = voltureChangeQr.getExciseTranscode('Imposta usi domestici');
        Test.stopTest();

        System.assert(results.size() > 0, 'Record non trovati');
    }

    @IsTest
    static void getContactInfosByAccountIdTst()
    {
        List<Account> accList = [SELECT Id FROM Account];
        List<AccountContactRelation> acrList = [SELECT Roles FROM AccountContactRelation WHERE AccountId = :accList[0].Id];
        acrList[0].Roles = 'Titolare';
        update acrList;

        Test.startTest();
        List<AccountContactRelation> acrTestList = voltureChangeQr.getContactInfosByAccountId(accList[0].Id);
        Test.stopTest();

        System.assertEquals(1, acrTestList.size(),'Record non trovati');
    }

    @IsTest
    static void getOrderInfosByIdTst()
    {
        List<Order> orderList = [SELECT Id FROM Order];

        Test.startTest();
        List<Order> orderTestList = voltureChangeQr.getOrderInfosById(orderList[0].Id);
        Test.stopTest();

        System.assertEquals(1, orderTestList.size(), 'Record non trovati');
    }

    @IsTest
    static void getDataEnrichmentTranscodeByObjectNameTst()
    {
        Test.startTest();
        List<HDT_GenericDataEnrichmentTranscode__mdt> results = voltureChangeQr.getDataEnrichmentTranscodeByObjectName(new List<String>{'Order'});
        Test.stopTest();

        System.assert(results.size() > 0, 'Record non trovati');
    }


}
