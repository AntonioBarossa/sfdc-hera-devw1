/**@frpanico 12/10/2021
 * Test Class for the class HDT_SRV_VoltureChangeManager
 */
@IsTest
public with sharing class HDT_SRV_VoltureChangeManagerTst {
    
    /**@frpanico 12/10/2021
     * Covers only one test case to achieve target coverage
     */

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
        
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', recordTypeIdVolturaConSwitch, recordTypeNameVolturaConSwitch,'A','','','');
    }

    @IsTest
    static void cloneOrderAndUpdateTst()
    {
        HDT_SRV_VoltureChangeManager voltureManager = new HDT_SRV_VoltureChangeManager();
        HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

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
        List<OrderItem> orderItemList = voltureChangeQr.getOrderItemByOrderId(orderList[0].Id);

        System.assertEquals(1, orderList.size(),'Order non trovato');
        System.assertEquals(2, orderItemList.size(),'OrderItmes non trovati');

        Test.startTest();
        voltureManager.cloneOrderAndUpdate(orderList[0]);
        Test.stopTest();

        List<Order> newOrderList = [SELECT Id, ParentOrder__c, Phase__c FROM Order WHERE (ProcessType__c = 'Voltura con Switch' OR Phase__c = 'Annullato') AND ParentOrder__c != NULL];
        List<OrderItem> newOrderItemList = [SELECT Id FROM OrderItem];
        System.assertEquals(2, newOrderList.size(),'Order non trovati');
        System.Assert(orderList[0].ParentOrder__c == newOrderList[0].ParentOrder__c, 'Parent order non associato correttamente');
        System.Assert(orderList[0].ParentOrder__c == newOrderList[1].ParentOrder__c, 'Parent order non associato correttamente');
        System.assertEquals(4, newOrderItemList.size(),'OrderItem non correttamente clonati');
        System.assert(newOrderList[0].Phase__c == 'Annullato' || newOrderList[0].Phase__c == 'Comunicazione verso Heroku', 'Fase non aggiornata correttamente');
        System.assert(newOrderList[1].Phase__c == 'Annullato' || newOrderList[1].Phase__c == 'Comunicazione verso Heroku', 'Fase non aggiornata correttamente');

    }

}
