@isTest
public with sharing class HDT_LC_AccountAlertsTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_AccountAlertsTst';
    
    
    //TEST SETUP
    
    
    
    
    //TESTS
    
    @isTest
    private static void getAccountAlertsTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getAccountAlertsTest';
        
        //SETUP
        Account acc = new Account();//TODO: USE ACCOUNT UNIFIED SETUP
        AlertAccountConfiguration__c myAlertConfig = new AlertAccountConfiguration__c();//TODO: USE AlertAccountConfiguration__c UNIFIED SETUP
        
        //...
        
        //TESTING
        String jsonResult = HDT_LC_AccountAlerts.getAccountAlerts(acc.Id);
        
        //ASSERTS
        System.assert(String.isNotBlank(jsonResult));
        //System.assertEquals(JSON.deserialize(jsonString, AlertAccountConfiguration__c));
    }
    
    
    
}
