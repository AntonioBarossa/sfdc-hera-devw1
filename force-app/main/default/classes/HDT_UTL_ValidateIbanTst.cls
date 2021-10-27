/*
    @Author:        Francesco Vitiello
    CreatedDate:    08/09/2021
*/

@isTest
public with sharing class HDT_UTL_ValidateIbanTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_ValidateIbanTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void validateIbanTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateIbanTest';
        System.debug(debugString);
        
        //SETUP

        List<HDT_UTL_ValidateIban.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_ValidateIban.HDT_UTL_FlowInputs>();
        HDT_UTL_ValidateIban.HDT_UTL_FlowInputs myInput = new HDT_UTL_ValidateIban.HDT_UTL_FlowInputs();
        myInput.iban = 'IT60X0542811101000000123456';
        inputs.add(myInput);

        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_ValidateIban.validateIban(inputs);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(inputs != null, 'Attenzione, inputs non può essere vuoto!');
        
    }

}

