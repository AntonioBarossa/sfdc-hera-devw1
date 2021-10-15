@isTest
public with sharing class HDT_TRH_NewsNotificationCenterTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_TRH_NewsNotificationCenterTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void getPotentialDuplicateTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getPotentialDuplicateTest';
        System.debug(debugString);
        
        //SETUP

        NewsNotificationCenter__c myNews = new NewsNotificationCenter__c();
        myNews.EntryChannel__c = 'Protocollo';
        myNews.Cluster__c = 'Modifiche Anagrafiche';
        myNews.Role__c = 'Back Office';
        myNews.Active__c = true;
        insert myNews;

        NewsNotificationCenter__c myNews2 = new NewsNotificationCenter__c();
        myNews2.EntryChannel__c = 'Protocollo';
        myNews2.Cluster__c = 'Modifiche Anagrafiche';
        myNews2.Role__c = 'Back Office';
        myNews2.Active__c = true;

        
        //TESTING
        Test.startTest();
        try{
            insert myNews2;
        }catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        //ASSERTS
        System.assert(myNews != null, 'Attenzione, myNews non può essere null!');
        System.assert(myNews2 != null, 'Attenzione, myNews2 non può essere null!');
        
    }


}
