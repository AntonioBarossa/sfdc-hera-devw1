@isTest
public with sharing class HDT_SRV_SelfReadingsFacadeTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_SelfReadingsFacadeTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    //TESTS
    
    ///CheckAutolettura
    @isTest
    private static void executeTest() {
        
		//DEBUG
		String debugString = TEST_NAME + ' - executeTest';
		System.debug(debugString);
        
        //SETUP
        mySetup();
        
        //PREPARAZIONE ARGS
        Case myCase = [SELECT Id FROM Case];
        
        Map<String,Object> parameters = new Map<String,Object>();
        parameters.put('requestType', 'CheckAutolettura');//TODO: IMPLEMENTARE CASI ALTERNATIVI
        
        
        Map<String,Object> argsMap = new Map<String,Object>();
        argsMap.put('method', '');//NB: PARAMETRO NON UTILIZZATO IN CODICE
        argsMap.put('sender', myCase);
        argsMap.put('parameters', parameters);
        
        
        String args = JSON.serialize(argsMap);
        
        //TESTING
        HDT_SRV_SelfReadingsFacade objToTest = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result;
        result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) objToTest.execute(args);
        
        //RETRIEVING DATA
        
        
        //ASSERTS
        
        
    }
    
    ///InvioLettureForzato
    
    
}
