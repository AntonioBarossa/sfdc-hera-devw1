@isTest
public with sharing class HDT_LC_SelfReadingTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_SelfReadingTst';
    
    //TEST SETUP
    
    //SETUP WITH CASE MOROSITà
    private static void setupMorosita(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    
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
        setupMorosita();
        Case myCase = [SELECT Id FROM Case];
        
        Reading__c myReading = new Reading__c();
        myReading.CaseGas__c = myCase.Id;
        insert myReading;
        String myReadingSTR = JSON.serialize(myReading);
        
        //TESTING
        Id result = HDT_LC_SelfReading.getReadingId('Case', myReading.Id, 'Gas');
        
        //ASSERTS
        System.assertNotEquals(null, result);
        System.assertEquals(myReading.Id, result);
        
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
