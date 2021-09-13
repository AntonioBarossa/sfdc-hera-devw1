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
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        
        //TEST ServicePoint__c
        ServicePoint__c myServPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];
        String myId = myServPoint.Id;
        
        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'cluster');
        paramsMap.put('context', myId);
        
        
        //TESTING
        System.debug(debugString + ' - Testing ServicePoint__c');
        HDT_SRV_InformativeManager myTstObj = new HDT_SRV_InformativeManager();
        String result = myTstObj.getOptions(JSON.serialize(paramsMap));
        
        //ASSERTS
        
        
        
        
        
        //TEST BillingProfile__c
        BillingProfile__c myBillingProfile = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id)[0];
        myId = myBillingProfile.Id;
        
        //TESTING
        System.debug(debugString + ' - Testing BillingProfile__c');
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'cluster');
        paramsMap.put('context', myId);
        
        //ASSERTS
        
        
        
    }
    
    //Topic
    //getOptions_Topic_Test
    
    
    //Process
    //getOptions_Process_Test
    
    
    //Info
    //getOptions_Info_Test
    
    
    
    
}
