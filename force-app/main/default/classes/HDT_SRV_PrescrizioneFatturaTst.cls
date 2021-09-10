@isTest
public with sharing class HDT_SRV_PrescrizioneFatturaTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_PrescrizioneFatturaTst';
    
    //DATA
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    
    
    
    //TESTS
    //execute
    private static void executeTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - executeTest_ok';
        
        //SETUP
        
        
        
        //
        SObject placeholder = new Case();
        
        Map<String, Object> argsMap = new Map<String,Object>();
        argsMap.put('sender', placeholder);
        
        //TESTING
        HDT_SRV_PrescrizioneFattura myObject = new HDT_SRV_PrescrizioneFattura();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse result = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) myObject.execute(argsMap);
        
        //
        
        //ASSERTS
        
        
    }
    
    
    
}
