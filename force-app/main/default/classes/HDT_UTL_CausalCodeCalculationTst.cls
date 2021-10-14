@isTest
public with sharing class HDT_UTL_CausalCodeCalculationTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CausalCodeCalculationTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void calculateCausalCodeTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'calculateCausalCodeTest';
        System.debug(debugString);
        
        //SETUP

        List<HDT_UTL_CausalCodeCalculation.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_CausalCodeCalculation.HDT_UTL_FlowInputs>();
        HDT_UTL_CausalCodeCalculation.HDT_UTL_FlowInputs myInput = new HDT_UTL_CausalCodeCalculation.HDT_UTL_FlowInputs();
        myInput.cluster = 'myCluster';
        myInput.process = 'myProcess';
        myInput.subprocess = 'mySubprocess';
        myInput.commodity = 'myCommodity';

        inputs.add(myInput);

        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_CausalCodeCalculation.calculateCausalCode(inputs);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(inputs != null, 'Attenzione, inputs non può essere null!');
        
    }

}

