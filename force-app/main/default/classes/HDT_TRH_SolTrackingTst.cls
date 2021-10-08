@isTest
public with sharing class HDT_TRH_SolTrackingTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_TRH_SolTrackingTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void replaceUserTagsTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'replaceUserTagsTest';
        System.debug(debugString);
        
        //SETUP
        List<SolTracking__c> myList = new List<SolTracking__c>();
        SolTracking__c mySol1 = new SolTracking__c();
        SolTracking__c mySol2 = new SolTracking__c();
        SolTracking__c mySol3 = new SolTracking__c();
        SolTracking__c mySol4 = new SolTracking__c();

        mySol1.Text__c = 'Sol1 contains UserTag';
        mySol2.Text__c = 'Sol2 contains UserTag';
        mySol3.Text__c = 'Sol3 contains UserTag';
        mySol4.Text__c = 'Sol4 contains UserTag';

        myList.add(mySol1);
        myList.add(mySol2);
        myList.add(mySol3);
        myList.add(mySol4);

        
        //TESTING
        Test.startTest();
        Try{
            insert myList;            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myList != null, 'Attenzione, myList non può essere null!');        
    }

}

