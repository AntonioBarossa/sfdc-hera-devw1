@isTest
public with sharing class HDT_UTL_ComboboxOptionsFactoryTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_ComboboxOptionsFactoryTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void getInstanceTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getInstanceTest';
        System.debug(debugString);
        
        //SETUP
        
        String serviceClass = 'HDT_SRV_InformativeManager';

        //TESTING
        Test.startTest();
        Try{
                        
            HDT_UTL_ComboboxOptionsInterface myComboBox = HDT_UTL_ComboboxOptionsFactory.getInstance(serviceClass);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(serviceClass != null, 'Attenzione, serviceClass non può essere null!');
        
    }


}
