/*
    @Author:        Francesco Vitiello
    CreatedDate:    28/09/2021
*/

@isTest
public with sharing class HDT_UTL_DocumentalManagementFactoryTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_DocumentalManagementFactoryTst';
    
    
    //TEST SETUP
    
    
    //TESTS

    @isTest
    private static void getInstanceTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'getInstanceTest';
        System.debug(debugString);
        
        //SETUP
        
        String classString = 'HDT_UTL_PayloadManagement';

        //TESTING
        Test.startTest();
        Try{
                        
            HDT_UTL_DocumentalManagementInterface myComboBox = HDT_UTL_DocumentalManagementFactory.getInstance(classString);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(classString != null, 'Attenzione, classString non può essere null!');
        
    }


}

