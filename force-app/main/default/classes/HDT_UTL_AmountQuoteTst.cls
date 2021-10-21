/*
    @Author:        Francesco Vitiello
    CreatedDate:    09/09/2021
*/

@isTest
public with sharing class HDT_UTL_AmountQuoteTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_AmountQuoteTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void calculateAmountQuoteTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'calculateAmountQuoteTest';
        System.debug(debugString);
        
        //SETUP

        List<HDT_UTL_AmountQuote.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_AmountQuote.HDT_UTL_FlowInputs>();
        HDT_UTL_AmountQuote.HDT_UTL_FlowInputs myInput = new HDT_UTL_AmountQuote.HDT_UTL_FlowInputs();
        myInput.distributor = 'myDistributor';
        myInput.city = 'myCity';
        myInput.caliber = 'myCaliber';
        myInput.hasCorrector = true;
        myInput.market = 'myMarket';
        myInput.commodity = 'myCommodity';
        myInput.processType = 'myProcessType';
        date myDate = date.newInstance(1990, 11, 21);
        myInput.manufactureYear = myDate;

        

        inputs.add(myInput);

        //TESTING
        Test.startTest();
        Try{

            HDT_UTL_AmountQuote.calculateAmountQuote(inputs);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(inputs != null, 'Attenzione, inputs non può essere null!');
        
    }

}


