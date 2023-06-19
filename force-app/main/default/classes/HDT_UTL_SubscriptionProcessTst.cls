@isTest
public with sharing class HDT_UTL_SubscriptionProcessTst
{
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    
    static void firstSetup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
 
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'D3 - Azienda', 'Aziende Soho');
        accList[0].VATNumber__c = '49130710046';
        insert accList;
        
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Product2> prodList = HDT_UTL_DataFactoryTst.createProduct2(2, false);
        prodList[0].Family = 'Offerta commerciale';
        insert prodList;
        Id priceBookId = Test.getStandardPriceBookId();
        PricebookEntry pbEntry = new PriceBookEntry(Pricebook2Id = priceBookId, Product2Id = prodList[0].Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry pbEntryTwo = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prodList[1].Id, UnitPrice = 1000, IsActive = true);
        insert pbEntry;
        insert pbEntryTwo;

        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(4, false, accList[0].Id, 'Bozza');
        orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        orderList[0].ServicePoint__c = spList[0].Id;
        orderList[0].Pricebook2Id = priceBookId;
        insert orderList[0];
        List<Order> orderListTwo = new List<Order>();
        orderList[1].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
        orderList[1].ServicePoint__c = spList[0].Id;
        orderList[1].Pricebook2Id = priceBookId;
        orderList[1].OrderReference__c = orderList[0].Id;
        orderListTwo.add(orderList[1]);
        orderList[2].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
        orderList[2].ServicePoint__c = spList[0].Id;
        orderList[2].Pricebook2Id = priceBookId;
        orderListTwo.add(orderList[2]);
        orderList[3].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
        orderList[3].ServicePoint__c = spList[0].Id;
        orderList[3].Pricebook2Id = priceBookId;
        orderList[3].VasSubType__c = 'Analisi Consumi';
        orderListTwo.add(orderList[3]);
        insert orderListTwo;
        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, false, orderList[0].Id, null, saleList[0].Id, 'Quote');
        quoteList[0].IsFromVasSection__c = true;
        insert quoteList;
        for (Integer i = 1; i<4; i++){
            orderList[i].SBQQ__Quote__c = quoteList[0].Id;
        }
        update orderList;
        List<OrderItem> orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(4, false, orderList[0].Id, spList[0].Id, prodList[0].Id, pbEntry.Id);
        orderItemList[0].OrderId = orderList[0].Id;
        orderItemList[0].Product2Id = prodList[0].Id;
        orderItemList[0].PricebookEntryId = pbEntry.Id;
        orderItemList[1].OrderId = orderList[1].Id;
        orderItemList[1].Product2Id = prodList[1].Id;
        orderItemList[1].PricebookEntryId = pbEntryTwo.Id;
        orderItemList[2].OrderId = orderList[2].Id;
        orderItemList[2].Product2Id = prodList[1].Id;
        orderItemList[2].PricebookEntryId = pbEntryTwo.Id;
        orderItemList[3].OrderId = orderList[3].Id;
        orderItemList[3].Product2Id = prodList[1].Id;
        orderItemList[3].PricebookEntryId = pbEntryTwo.Id;
        insert orderItemList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(4, false, accList[0].Id);
        contractList[0].SBQQ__Order__c = orderList[0].Id;
        contractList[1].SBQQ__Order__c = orderList[1].Id;
        contractList[2].SBQQ__Order__c = orderList[2].Id;
        contractList[3].SBQQ__Order__c = orderList[3].Id;
        insert contractList;

        orderList[2].ContractReference__c = contractList[0].Id;
        update orderList[2];

        List<SBQQ__Subscription__c> subList = HDT_UTL_DataFactoryTst.createSubscription(4, false, accList[0].Id, contractList[0].Id, spList[0].Id);
        List<SBQQ__Subscription__c> subListTest = new List<SBQQ__Subscription__c>();
        subList[0].SBQQ__Product__c = prodList[0].Id;
        subList[0].SBQQ__Contract__c = contractList[0].Id;
        subList[0].SBQQ__OrderProduct__c = orderItemList[0].Id;
        insert subList[0];
        subList[1].SBQQ__Contract__c = contractList[1].Id;
        subList[1].SBQQ__Product__c = prodList[1].Id;
        subList[1].SBQQ__OrderProduct__c = orderItemList[1].Id;
        insert subList[1];
        subList[2].SBQQ__Contract__c = contractList[2].Id;
        subList[2].SBQQ__Product__c = prodList[1].Id;
        subList[2].SBQQ__OrderProduct__c = orderItemList[2].Id;
        insert subList[2];
        subList[3].SBQQ__Contract__c = contractList[3].Id;
        subList[3].SBQQ__Product__c = prodList[1].Id;
        subList[3].SBQQ__OrderProduct__c = orderItemList[3].Id;
        insert subList[3];

        insert subListTest;
    }

    static void secondSetup(){
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        //List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(2, true, accList[0].id);
        List<AccountContactRelation> accContRelations = new List<AccountContactRelation>();
        for (AccountContactRelation accContRelation : [SELECT id FROM AccountContactRelation WITH SECURITY_ENFORCED]){
            accContRelation.Roles = 'Other';
            accContRelations.add(accContRelation);
        }
        accContRelations[1].Roles = 'Titolare';
        update accContRelations;
        List<Pricebook2> pb = HDT_UTL_DataFactoryTst.createPricebook(1,true);
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(2, false);
        productList[0].Name = 'Analisi Consumi';
        productList[0].Family = 'VAS Fatturabili';
        productList[0].ProductCode = 'VAS_AS_HERA';

        productList[1].Name = 'Prezzo Netto';
        productList[1].Family = 'Offerta commerciale';
        productList[1].ProductCode = 'PRZ_NTT';
        insert productList;


        productList  = [SELECT Id FROM Product2];
        Product2 prodOffer = [SELECT Id FROM Product2 where Family = 'Offerta commerciale'];
        Product2 prodAnaCons = [SELECT Id FROM Product2 where Family = 'VAS Fatturabili'];
        pb = [SELECT Id from Pricebook2 WHERE isStandard = false LIMIT 1];
        Pricebook2 pbStandard = [SELECT Id from Pricebook2 WHERE isStandard = true LIMIT 1];
        List<PricebookEntry> pbe = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, pb[0].Id,pbStandard.Id);
        SBQQ__ProductOption__c po = HDT_UTL_DataFactoryTst.createProductOption(productList[0].Id,productList[1].Id,true);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false, accList[0].Id);
        billingProfileList[0].InvoicingStreetName__c = 'Roma';
        billingProfileList[0].InvoicingStreetNumber__c = '15';
        billingProfileList[0].InvoicingStreetNumberExtension__c = '20100 ITALIA';
        billingProfileList[0].InvoicingCity__c = 'ROMA';
        billingProfileList[0].InvoicingProvince__c = 'RM';
        billingProfileList[0].InvoicingPostalCode__c = '10190';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';

        insert billingProfileList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].id);
        contractList[0].Status = 'Attivo';
        insert contractList;

        Contract contr = [SELECT Id FROM Contract LIMIT 1];

        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = contr.Id, 
            SBQQ__Product__c = prodOffer.Id, 
            SBQQ__Quantity__c = 1, 
            SBQQ__Account__c = accList[0].Id,
            SBQQ__NetPrice__c = 100.2,
            SBQQ__SubscriptionEndDate__c = Date.Today());
        insert subs;
    }

    @isTest
    static void adjustVasContractBeforeInsertTst()
    {
        firstSetup();
        Test.startTest();
            Boolean testResult = true;
            List<SBQQ__Subscription__c> subList = [SELECT Id, SBQQ__RequiredById__c FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Family != 'Offerta commerciale'];
            for(SBQQ__Subscription__c sub : subList)
            {
                if(sub.SBQQ__RequiredById__c == null)
                {
                    testResult = false;
                    break;
                }
            }
        Test.stopTest();
        System.assertEquals(true, testResult, 'Subscription non riconciliate');
    }

    @isTest
    static void adjustLookup()
    {
        secondSetup();
        Test.startTest();
        Product2 prodAnaCons = [SELECT Id FROM Product2 where Family = 'VAS Fatturabili'];
        Contract contr = [SELECT Id FROM Contract LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c(
            SBQQ__Contract__c = contr.Id, 
            SBQQ__Product__c = prodAnaCons.Id, 
            SBQQ__Quantity__c = 1, 
            SBQQ__Account__c = acc.Id,
            SBQQ__NetPrice__c = 100.2,
            SBQQ__SubscriptionEndDate__c = Date.Today(),
            SBQQ__OptionType__c = 'Related Product');
        insert subs;
        subs.SBQQ__RootId__c = subs.Id;
        update subs;
        Test.stopTest();
        //System.assertEquals(true, testResult, 'Subscription non riconciliate');
    }

    @isTest
    static void testFinalizer()
    {
        secondSetup();
        List<Contract> cs = [Select id from Contract];
        List<SBQQ__Subscription__c> subs = [Select id from SBQQ__Subscription__c];
        subs[0].SBQQ__Quantity__c = 2;
        Test.startTest();
        Finalizer f = new HDT_UTL_SubscriptionProcess.HDT_QBL_Finalizer(new List<Contract>(), new List<SBQQ__Subscription__c>(), subs);
        f.execute(null);
        subs = [Select id from SBQQ__Subscription__c];
        f = new HDT_UTL_SubscriptionProcess.HDT_QBL_Finalizer(cs, subs, new List<Sobject>());
        f.execute(null);
        Test.stopTest();
        
    }

    @isTest
    static void testTari()
    {
        secondSetup();
        List<SBQQ__Subscription__c> oldSub = [Select SBQQ__Contract__c, SBQQ__Contract__r.AccountId, SBQQ__Product__c from SBQQ__Subscription__c];
        Contract cs = oldSub[0].SBQQ__Contract__r;
        List<PricebookEntry> lpbe = [Select id from PricebookEntry LIMIT 1];
        List<Pricebook2> lpb = [Select id from Pricebook2 LIMIT 1];
        Id prodId = oldSub[0].SBQQ__Product__c;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, cs.AccountId, 'Bozza');
        orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        //orderList[0].ServicePoint__c = spList[0].Id;
        orderList[0].Commodity__c = 'Ambiente';
        orderList[0].EffectiveDate__c = Date.today();
        orderList[0].Pricebook2Id = lpb[0].Id;
        insert orderList[0];

        List<OrderItem> orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(5, false, orderList[0].Id, null, prodId, lpbe[0].Id);
        orderItemList[0].OrderId = orderList[0].Id;
        orderItemList[0].Product2Id = prodId;
        orderItemList[0].PricebookEntryId = lpbe[0].Id;
        insert orderItemList[0];

        Test.startTest();
        List<SBQQ__Subscription__c> subList = HDT_UTL_DataFactoryTst.createSubscription(1, false, cs.AccountId, cs.Id, null);
        subList[0].SBQQ__Contract__c = cs.Id;
        subList[0].SBQQ__Product__c = prodId;
        subList[0].SBQQ__OrderProduct__c = orderItemList[0].Id;
        subList[0].SBQQ__Quantity__c = -1;
        //system.debug('ivaste_final' + [Select id From SBQQ__Subscription__c where SBQQ__Contract__c =:subList[0].SBQQ__Contract__c AND ]);
        insert subList;
        Test.stopTest();
        system.debug('ivaste_final' + [Select Count() From SBQQ__Subscription__c]);
    }

}