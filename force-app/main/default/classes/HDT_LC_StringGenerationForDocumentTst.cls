@isTest
public with sharing class HDT_LC_StringGenerationForDocumentTst {
    @TestSetup
    static void makeData(){
        StaticStringForDocuments__c fakeString = new StaticStringForDocuments__c(Process__c = 'process', 
                                                                                 Subprocess__c = 'subprocess',
                                                                                 Municipality__c = null);
        insert fakeString;

        Profile profileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User usr = new User(LastName = 'TEST',
                        FirstName='Fail',
                        Alias = 'ftest',
                        Email = 'f.test@asdf.com',
                        Username = 'f.test@asdf.com',
                        ProfileId = profileId.id,
                        TimeZoneSidKey = 'GMT',
                        LanguageLocaleKey = 'en_US',
                        EmailEncodingKey = 'UTF-8',
                        LocaleSidKey = 'en_US'
                        );
        insert usr;
    }

    @isTest
    static void test_fail(){
        test.startTest();
            User testUser = [SELECT Id FROM User WHERE alias = 'ftest'];
            System.runAs(testUser){
                List<StaticStringForDocuments__c> listStringDocumental = new List<StaticStringForDocuments__c>();
                try{
                    listStringDocumental = HDT_LC_StringGenerationForDocument.getUniqueString(null,null,null);
                } catch (AuraHandledException ex) {
                    System.assertEquals('Script-thrown exception', ex.getMessage());
                }
            }
        test.stopTest();
    }

    @isTest
    static void test(){
        
        Test.startTest();
            List<StaticStringForDocuments__c> listStringDocumental = HDT_LC_StringGenerationForDocument.getUniqueString('cityFail', 'process', 'subprocess');
        Test.stopTest();
        system.assertEquals(null, listStringDocumental[0].Municipality__c);
        system.assertEquals('process', listStringDocumental[0].Process__c);
        system.assertEquals('subprocess', listStringDocumental[0].Subprocess__c);
    }
}
