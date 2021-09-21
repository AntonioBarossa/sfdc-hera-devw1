@isTest
public with sharing class HDT_UTL_CasePrivacyValidationsTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CasePrivacyValidationsTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void validateTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateTest';
        System.debug(debugString);
        
        //SETUP
        
        List<Individual> myIndividualList = HDT_UTL_DataFactoryTst.createIndividual(1,true);
        Individual myIndividual = myIndividualList[0];
        myIndividual.HasOptedOutOfEmail__c = true;
        myIndividual.HasOptedOutSoftSpam__c = true;
        myIndividual.MarketingPrivacy__c = 'Non espresso';
        myIndividual.ProfilingPrivacy__c = 'Non espresso';
        String recordId = myIndividual.Id;
        String fields = JSON.serialize(myIndividualList);

        //TESTING
        Test.startTest();
        Try{
            
            HDT_UTL_CasePrivacyValidations myClass = new HDT_UTL_CasePrivacyValidations();
            myClass.validate(fields, recordId); 
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myIndividualList != null);
        System.assert(recordId != null);
        System.assert(fields != null);
        
    }


}
