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
    private static void getOptionsTest() {
        
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
        System.debug(debugString + ' - Testing CLUSTER');
        System.debug(debugString + ' - Testing ServicePoint__c');
        HDT_SRV_InformativeManager myTstObj = new HDT_SRV_InformativeManager();
        
        String result = myTstObj.getOptions(JSON.serialize(paramsMap));
        List<Map<String,String>> resultProcessed = (List<Map<String,String>>) JSON.deserialize(result, List<Map<String,String>>.class);
        
        //ASSERTS
        System.assert(resultProcessed.size() > 0,'OK');
        System.assertNotEquals(null, resultProcessed[0].get('label'),'OK');
        System.assertNotEquals(null, resultProcessed[0].get('value'),'OK');
        
        
        //TEST BillingProfile__c
        BillingProfile__c myBillingProfile = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id)[0];
        myId = myBillingProfile.Id;
        
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'cluster');
        paramsMap.put('context', myId);
        
        //TESTING
        System.debug(debugString + ' - Testing BillingProfile__c');
        result = myTstObj.getOptions(JSON.serialize(paramsMap));
        resultProcessed = (List<Map<String,String>>) JSON.deserialize(result, List<Map<String,String>>.class);
        
        //ASSERTS
        System.assert(resultProcessed.size() > 0,'OK');
        System.assertNotEquals(null, resultProcessed[0].get('label'),'OK');
        System.assertNotEquals(null, resultProcessed[0].get('value'),'OK');
        
        
        
        //Topic
        //TESTING
        System.debug(debugString + ' - Testing TOPIC');
        System.debug(debugString + ' - Testing ServicePoint__c');
        myId = myServPoint.Id;
        
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'topic');
        paramsMap.put('context', myId);
        paramsMap.put('cluster', 'Disattivazioni');
        
        result = myTstObj.getOptions(JSON.serialize(paramsMap));
        resultProcessed = (List<Map<String,String>>) JSON.deserialize(result, List<Map<String,String>>.class);
        
        //ASSERTS
        System.assert(resultProcessed.size() > 0,'OK');
        System.assertNotEquals(null, resultProcessed[0].get('label'),'OK');
        System.assertNotEquals(null, resultProcessed[0].get('value'),'OK');
        
        
        //TESTING
        System.debug(debugString + ' - Testing BillingProfile__c');
        myId = myBillingProfile.Id;
        
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'topic');
        paramsMap.put('context', myId);
        paramsMap.put('cluster', 'Pagamenti');
        
        result = myTstObj.getOptions(JSON.serialize(paramsMap));
        resultProcessed = (List<Map<String,String>>) JSON.deserialize(result, List<Map<String,String>>.class);
        
        //ASSERTS
        System.assert(resultProcessed.size() > 0,'OK');
        System.assertNotEquals(null, resultProcessed[0].get('label'),'OK');
        System.assertNotEquals(null, resultProcessed[0].get('value'),'OK');
        
        
        
        //process
        //TESTING
        System.debug(debugString + ' - Testing PROCESS');
        
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'process');
        paramsMap.put('cluster', 'Autolettura');
        
        result = myTstObj.getOptions(JSON.serialize(paramsMap));//RETURNA STRING DIRETTO
        //resultProcessed = (List<Map<String,String>>) JSON.deserialize(result, List<Map<String,String>>.class);
        
        //ASSERTS
        System.assertNotEquals(null, result,'OK');
        
        
        
        //info
        //TESTING
        System.debug(debugString + ' - Testing INFO');
        System.debug(debugString + ' - Testing ServicePoint__c');
        myId = myServPoint.Id;
        
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'info');
        paramsMap.put('context', myId);
        paramsMap.put('topic', 'Info stato pratica');
        paramsMap.put('cluster', 'Disattivazioni');
        
        result = myTstObj.getOptions(JSON.serialize(paramsMap));
        resultProcessed = (List<Map<String,String>>) JSON.deserialize(result, List<Map<String,String>>.class);
        
        //ASSERTS
        System.assert(resultProcessed.size() > 0,'OK');
        System.assertNotEquals(null, resultProcessed[0].get('label'),'OK');
        System.assertNotEquals(null, resultProcessed[0].get('value'),'OK');
        
        
        //TESTING
        System.debug(debugString + ' - Testing BillingProfile__c');
        myId = myBillingProfile.Id;
        
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'info');
        paramsMap.put('context', myId);
        paramsMap.put('topic', 'Info modalità');
        paramsMap.put('cluster', 'Pagamenti');
        
        result = myTstObj.getOptions(JSON.serialize(paramsMap));
        resultProcessed = (List<Map<String,String>>) JSON.deserialize(result, List<Map<String,String>>.class);
        
        //ASSERTS
        System.assert(resultProcessed.size() > 0,'OK');
        System.assertNotEquals(null, resultProcessed[0].get('label'),'OK');
        System.assertNotEquals(null, resultProcessed[0].get('value'),'OK');
        
        
        //else
        //TESTING
        System.debug(debugString + ' - Testing ELSE');
        System.debug(debugString + ' - Testing ServicePoint__c');
        myId = myServPoint.Id;
        
        paramsMap = new Map<String, Object>();
        paramsMap.put('method', 'else');
        paramsMap.put('context', myId);
        
        result = myTstObj.getOptions(JSON.serialize(paramsMap));
        
        //ASSERTS
        System.assertEquals(null, result,'KO');
        
    }
    
}
