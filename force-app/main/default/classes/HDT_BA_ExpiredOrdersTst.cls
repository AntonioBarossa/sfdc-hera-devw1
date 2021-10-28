@isTest
public with sharing class HDT_BA_ExpiredOrdersTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_BA_ExpiredOrdersTst';
    
    
    //DATA
	private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        Id recTypeId = utlConstants.ORDER_RECORDTYPEID_CAMBIO_OFFERTA;
        String recTypeName = utlConstants.ORDER_RECORDTYPE_CAMBIO_OFFERTA;
        HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza', recTypeId, recTypeName);
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id); 
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, 'Bozza');
        for(Order o : ordList){
            o.DocusignExpirationDate__c = Date.today().addDays(5);
            o.RecordTypeId = recTypeId;
            o.Contact__c = conList[0].Id;
        }
        
        Order mySingleOrder = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza')[0];
        mySingleOrder.RecordTypeId = recTypeId;
        mySingleOrder.Contact__c = conList[0].Id;
        
        ordList.add(mySingleOrder);
        insert ordList;
    }
    
    
    //TESTS
    
    @isTest
    private static void myBatchTest() {
        
        //SETUP
        mySetup();
        Order myOrder = [SELECT Id FROM Order LIMIT 1];
        
        //UPDATING ORDER FOR BATCH
        myOrder.DocusignExpirationDate__c = Date.today().addDays(-10);
        update myOrder;
        
        //TESTING
        Test.startTest();
        HDT_BA_ExpiredOrders myBatchToTest = new HDT_BA_ExpiredOrders();
        Database.executeBatch(myBatchToTest);
        Test.stopTest();
        
        //RETRIEVING DATA
        Order myUpdatedOrder = [SELECT Id, Phase__c, CancellationReason__c FROM Order WHERE Id = :myOrder.Id];
        Order myRegularOrder = [SELECT Id, Phase__c, CancellationReason__c FROM Order WHERE Id != :myOrder.Id AND DocusignExpirationDate__c != Null];
        Order myUnaffectedOrder = [SELECT Id, Phase__c, CancellationReason__c FROM Order WHERE DocusignExpirationDate__c = Null];
        
        //ASSERTS
        System.assert('Annullato'.equalsIgnoreCase(myUpdatedOrder.Phase__c), 'Ordine NON è in Fase Annullato');
        System.assert('Annullato per no conferma cliente'.equalsIgnoreCase(myUpdatedOrder.CancellationReason__c), 'Ordine risulta NON annullato.');
        
        System.assert(!'Annullato'.equalsIgnoreCase(myRegularOrder.Phase__c), 'Ordine è in Fase Annullato, non previsto.');
        System.assert(!'Annullato per no conferma cliente'.equalsIgnoreCase(myRegularOrder.CancellationReason__c), 'Ordine risulta annullato.');
        
        System.assert(!'Annullato'.equalsIgnoreCase(myUnaffectedOrder.Phase__c), 'Ordine non deve essere alterato se non ha DocusignExpirationDate__c.');
        System.assert(!'Annullato per no conferma cliente'.equalsIgnoreCase(myUnaffectedOrder.CancellationReason__c), 'Ordine senza scadenza risulta annullato.');
        
    }
    
}
