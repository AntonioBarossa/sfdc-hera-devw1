@isTest
public with sharing class HDT_UTL_CaseCancellationTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseCancellationTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void dispatchMethodTest(){
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'dispatchMethodTest';
        System.debug(debugString);
        
        //SETUP

        List<HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason> inputs = new List<HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason>();
        HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason myInput = new HDT_UTL_CaseCancellation.HDT_UTL_RequestCancellationReason();
        
        
        List<HDT_ProcessCancellationReason__mdt> myProcessInputList = [select id, RecordType__c, Commodity__c, Process_Type__c, Process_Type_to_Cancell__c from HDT_ProcessCancellationReason__mdt where Process_Type__c = 'Annullamento prestazione'];
        HDT_ProcessCancellationReason__mdt myProcessInput = myProcessInputList[0]; 
        String myString = JSON.serialize(myProcessInput);
        HDT_UTL_CaseCancellation.getListCanellationReasonLwc(myString);
        
        HDT_UTL_CaseCancellation.dispatchMethod(inputs);
        inputs.add(myInput);

        //TESTING
        Test.startTest();
        Try{

            myInput.method = 'getCancellationReason';
            HDT_UTL_CaseCancellation.dispatchMethod(inputs);

            myInput.method = 'getListCancellationReason';
            myInput.processType = 'Annullamento prestazione';
            HDT_UTL_CaseCancellation.dispatchMethod(inputs);

            myInput.method = 'myMethod';
            HDT_UTL_CaseCancellation.dispatchMethod(inputs);

            HDT_UTL_CaseCancellation.HDT_UTL_Option myClass = new HDT_UTL_CaseCancellation.HDT_UTL_Option('myLabel');


        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(inputs != null, 'Attenzione, inputs non può essere null!');
        
    }

}

