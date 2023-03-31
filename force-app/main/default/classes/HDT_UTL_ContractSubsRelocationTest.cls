@isTest
public with sharing class HDT_UTL_ContractSubsRelocationTest {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private final static String SAP_CONTR_CODE = 'TEST_CODE';

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
 
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'D3 - Azienda', 'Aziende Soho');
        accList[0].VATNumber__c = '49130710046';
        insert accList;
        
        HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Product2> prodList = HDT_UTL_DataFactoryTst.createProduct2(2, false);
        prodList[0].Family = 'Offerta commerciale';
        insert prodList;
        Id priceBookId = Test.getStandardPriceBookId();
        PricebookEntry pbEntry = new PriceBookEntry(Pricebook2Id = priceBookId, Product2Id = prodList[0].Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry pbEntryTwo = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = prodList[1].Id, UnitPrice = 1000, IsActive = true);
        insert pbEntry;
        insert pbEntryTwo;

        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(3, false, accList[0].Id, 'Bozza');
        orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        orderList[0].ServicePoint__c = spList[0].Id;
        orderList[0].Pricebook2Id = priceBookId;
        //insert orderList[0];

        orderList[1].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_CambioTariffa').getRecordTypeId();
        orderList[1].ServicePoint__c = spList[0].Id;
        orderList[1].Pricebook2Id = priceBookId;
        orderList[1].SAPContractCode__c = SAP_CONTR_CODE;
        orderList[1].EffectiveDate__c = date.today();
        orderList[1].Commodity__c = 'Ambiente';

        orderList[2].RecordTypeId = orderList[1].RecordTypeId;
        orderList[2].ServicePoint__c = spList[0].Id;
        orderList[2].Pricebook2Id = priceBookId;
        orderList[2].SAPContractCode__c = SAP_CONTR_CODE;
        orderList[2].EffectiveDate__c = date.today();
        orderList[2].Commodity__c = 'Ambiente';
        
        insert orderList;


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

        insert orderItemList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(3, false, accList[0].Id);
        contractList[0].SBQQ__Order__c = orderList[0].Id;
        contractList[0].SAPContractCode__c = SAP_CONTR_CODE;
        contractList[1].SBQQ__Order__c = orderList[1].Id;
        contractList[1].SAPContractCode__c = SAP_CONTR_CODE;
        contractList[2].SBQQ__Order__c = orderList[2].Id;
        contractList[2].SAPContractCode__c = SAP_CONTR_CODE;
        /*contractList[2].SBQQ__Order__c = orderList[2].Id;
        contractList[3].SBQQ__Order__c = orderList[3].Id;*/
        insert contractList;

        orderList[1].ContractReference__c = contractList[0].Id;
        orderList[2].ContractReference__c = contractList[0].Id;
        update new List<Order>{orderList[1], orderList[2]};

        List<SBQQ__Subscription__c> subList = HDT_UTL_DataFactoryTst.createSubscription(2, false, accList[0].Id, contractList[0].Id, spList[0].Id);
        //List<SBQQ__Subscription__c> subListTest = new List<SBQQ__Subscription__c>();
        subList[0].SBQQ__Product__c = prodList[0].Id;
        subList[0].SBQQ__Contract__c = contractList[0].Id;
        subList[0].SBQQ__OrderProduct__c = orderItemList[0].Id;
        subList[1].SBQQ__Contract__c = contractList[1].Id;
        subList[1].SBQQ__Product__c = prodList[1].Id;
        subList[1].SBQQ__OrderProduct__c = orderItemList[1].Id;
        insert subList;

        subList = HDT_UTL_DataFactoryTst.createSubscription(1, false, accList[0].Id, contractList[0].Id, spList[0].Id);

        subList[0].SBQQ__Contract__c = contractList[2].Id;
        subList[0].SBQQ__Product__c = prodList[1].Id;   
        subList[0].SBQQ__OrderProduct__c = orderItemList[2].Id;
        insert subList;
        
    }


    @isTest
    public static void fakeMoveInMoveOutTest(){
        Order o = [Select id, contractReference__c, SAPContractCode__c, ContractReference__r.SAPContractCode__c, RecordTypeId from Order where contractReference__c != null LIMIT 1];
        Contract c = new Contract(SAPContractCode__c = SAP_CONTR_CODE);
        Test.startTest();
        system.assert(
            new HDT_UTL_ContractSubscriptionRelocation().checkConditionsBefore(c, o),
            'Error checking condition'
        );
        Test.stopTest();
    }

    @isTest
    public static void deleteContracts(){
        Test.startTest();
        HDT_UTL_SubscriptionProcess.contractToDelete.addAll([Select id from Contract]);
        HDT_UTL_SubscriptionProcess.dmlOnAfterInsert();
        Test.stopTest();
        system.assertEquals(
            0,
            [Select Count() from Contract],
            'Errore cancellazione contratti'
        );
    }

    @isTest
    public static void deleteContractsFinalizers(){
        Test.startTest();
        HDT_UTL_SubscriptionProcess.HDT_QBL_Finalizer finalizer = new HDT_UTL_SubscriptionProcess.HDT_QBL_Finalizer([Select id from Contract]);
        finalizer.execute(null);
        system.assertEquals(
            0,
            [Select Count() from Contract],
            'Errore cancellazione contratti'
        );
        Test.stopTest();
        
    }

    
}