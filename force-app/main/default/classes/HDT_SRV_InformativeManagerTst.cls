@isTest
public with sharing class HDT_SRV_InformativeManagerTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_InformativeManagerTst';
    
    //DATA
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    
    //TEST SETUP
    
    
    
    //TESTS
    
    //getOptions
    @isTest
    private static void getOptions_Cluster_Test() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - getOptionsTest';
        System.debug(debugString);
        
        //TEST ServicePoint__c
        String myId = '';
        
        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'cluster');
        paramsMap.put('context', myId);
        
        
        //TESTING
        HDT_SRV_InformativeManager myTstObj = new HDT_SRV_InformativeManager();
        String result = myTstObj.getOptions(JSON.serialize(paramsMap));
        
        //ASSERTS
        
        
        //TEST BillingProfile__c
        
        
    }
    
    //Topic
    //getOptions_Topic_Test
    
    
    //Process
    //getOptions_Process_Test
    
    
    //Info
    //getOptions_Info_Test
    
    
    
    
}
