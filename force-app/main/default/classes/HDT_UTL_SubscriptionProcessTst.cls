@isTest
public with sharing class HDT_UTL_SubscriptionProcessTst
{
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup()
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


    @isTest
    static void adjustVasContractBeforeInsertTst()
    {
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

}