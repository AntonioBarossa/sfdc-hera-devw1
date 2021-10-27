@isTest
public with sharing class HDT_BA_ExpiredOrdersTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_BA_ExpiredOrdersTst';
    
    
    //DATA
    
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, true, accList[0].id, 'Bozza');
    }
    
    
    //TESTS
    
    @isTest
    private static void myBatchTest() {
        
        //SETUP
        mySetup();
        Order myOrder = [SELECT Id FROM Order LIMIT 1];
        
        //
        
    }
    
}
