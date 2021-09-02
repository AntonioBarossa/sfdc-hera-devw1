@isTest
public with sharing class HDT_LC_SelfReadingTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_SelfReadingTst';
    
    //TEST SETUP
    
    
    
    //TESTS
    
    //insertSelfReading
    @isTest
    private static void insertSelfReadingTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'insertSelfReadingTest';
        System.debug(debugString);
        
        //SETUP
        Reading__c myReading = new Reading__c();
        String myReadingSTR = JSON.serialize(myReading);
        
        //TESTING
        HDT_LC_SelfReading.insertSelfReading(myReadingSTR);
        
        //RETRIEVE DATA
        Reading__c result = [SELECT Id FROM Reading__c];
        
        //ASSERTS
        System.assertNotEquals(null, result);
        
    }
    
    //updateSelfReading
    @isTest
    private static void updateSelfReadingTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'updateSelfReadingTest';
        System.debug(debugString);
        
        //SETUP
        Reading__c myReading = new Reading__c();
        insert myReading;
        String myReadingSTR = JSON.serialize(myReading);
        
        //TESTING
        HDT_LC_SelfReading.updateSelfReading(myReadingSTR);
        
        //RETRIEVE DATA
        Reading__c result = [SELECT Id FROM Reading__c];
        
        //ASSERTS
        System.assertNotEquals(null, result);
        
    }
    
    
    //getReadingId
    //Gas
    @isTest
    private static void getReadingIdTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getReadingIdTest';
        System.debug(debugString);
        
        //SETUP
        Reading__c myReading = new Reading__c();
        insert myReading;
        String myReadingSTR = JSON.serialize(myReading);
        
        //TESTING
        Id result = HDT_LC_SelfReading.getReadingId('Reading__c', myReading.Id, 'Gas');
        
        //ASSERTS
        System.assertEquals(null, result);
        
    }
    
    //updateOrder
    
    
    //getRecordTypeId
    
    
    //checkLastReadings
    
    
    /*
    
    @AuraEnabled
    public static void updateSelfReading(String fields){
    }

    @AuraEnabled
    public static Id getReadingId(String objectName, Id objectId, String commodity){
    }

    @AuraEnabled
    public static string updateOrder(String fields, String recordId, Boolean isRetroactive, Boolean isReading, Date readingCustomerDate,Boolean completed){

    }


    @AuraEnabled
    public static string getRecordTypeId(String commodity){

    }

    @AuraEnabled
    public static String checkLastReadings(String servicePointId){

    }
    
    */
}
