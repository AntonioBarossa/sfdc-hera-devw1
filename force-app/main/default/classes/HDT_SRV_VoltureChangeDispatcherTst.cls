@IsTest
public with sharing class HDT_SRV_VoltureChangeDispatcherTst 
{
    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        //Create 1 order one for the parent and one for the child 1
        //Create 2 OrderItems (to test loop with more than one item)
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, false, accList[0].Id);  
        spList[0].CommoditySector__c = 'Energia Elettrica';
        update spList;
		
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<Order> childOrderList = HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, saleList, orderList[0].Id, contactList[0].Id);
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        //List<Pricebook2> priceBookList = HDT_UTL_DataFactoryTst.createPricebook(1, true);
        //List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, priceBookList[0].Id);
        orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(1, true, childOrderList[0].Id, spList[0].Id,productList[0].Id,'');
    }

    @IsTest
    static void cloneOrderAndUpdateTst()
    {
        List<Order> orderList = [SELECT Id FROM Order WHERE ParentOrder__c != null];
        List<OrderItem> orderItemList = [SELECT id FROM OrderItem WHERE OrderId = :orderList[0].Id];

        System.assertEquals(1, orderList.size(),'Order non trovato');
        System.assertEquals(2, orderItemList.size(),'OrderItmes non trovati');

    }


}
