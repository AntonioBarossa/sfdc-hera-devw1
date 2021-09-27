@isTest
public with sharing class HDT_SRV_ReminderBlockTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_ReminderBlockTst';
    
    
    //DATA
    //private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    
    
    //TEST SETUP
    private static void mySetup(){
        
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, true, acc[0].id, contactList[0].Id, servPoint.Id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    
    //TESTS
    
    @isTest
    private static void createRequestBodyTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - createRequestBodyTest';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        
        
    }
    
}
