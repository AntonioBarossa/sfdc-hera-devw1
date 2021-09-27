@isTest
public with sharing class HDT_SRV_ReminderBlockTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_ReminderBlockTst';
    
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static boolean isBlockType1 = true;
    
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        
        //CASE
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, false, acc[0].id, contactList[0].Id, servPointList[0].Id, contractList[0].id, ordList[0].id);
        Case myCase = caseList[0];
        
        if(isBlockType1){
            myCase.BlockType__c = '1 - Partite da chiarire/fatture errate o contestate';
        } else {
            myCase.BlockType__c = 'W - Verifica metrologica contatore in corso';
        }
        
        List<DocumentSelected__c> documents = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id, bpf[0].ContractAccountCode__c);
        
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
        Case myCase = [SELECT Id FROM Case];
        
        //TESTING
        HDT_SRV_ReminderBlock myTestObject = new HDT_SRV_ReminderBlock();
        myTestObject.createRequestBody(myCase.Id);
        
        //RETRIEVING DATA
        
        
        
        //ASSERTS
        
        
        
    }
    
}
