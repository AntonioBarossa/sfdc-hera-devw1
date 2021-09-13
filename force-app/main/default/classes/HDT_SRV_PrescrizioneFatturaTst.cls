@isTest
public with sharing class HDT_SRV_PrescrizioneFatturaTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_PrescrizioneFatturaTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    
    
    //TESTS
    //execute
    private static void executeTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_ok';
        
        //SETUP
        mySetup();
        
        Case obj = [SELECT Id, CaseNumber, ContractCode__c, ElementDetail__c FROM Case];
        System.debug(debugString + ' - case obj: ' + obj);
        
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('sender', obj);
        
        //TESTING
        HDT_SRV_PrescrizioneFattura myObject = new HDT_SRV_PrescrizioneFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObject.execute(argsMap);
        
        //ASSERTS
        System.assertEquals(Successo_Test, result.getBody());
        
    }
    
    
    
}
