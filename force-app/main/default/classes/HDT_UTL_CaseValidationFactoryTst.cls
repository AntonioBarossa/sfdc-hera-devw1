/*
    @Author:        Francesco Vitiello
    CreatedDate:    23/09/2021
*/

@isTest
public with sharing class HDT_UTL_CaseValidationFactoryTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseValidationFactoryTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void getInstanceTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getInstanceTest';
        System.debug(debugString);
        
        //SETUP
        
        String validationClass = 'HDT_UTL_CaseValidations';

        //TESTING
        Test.startTest();
        Try{
                        
            HDT_UTL_CaseValidationInterface myComboBox = HDT_UTL_CaseValidationFactory.getInstance(validationClass);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(validationClass != null, 'Attenzione, validationClass non può essere null!');
        
    }


}

