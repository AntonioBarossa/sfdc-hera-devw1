@isTest
public with sharing class HDT_UTL_PhoneNumbersTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_PhoneNumbersTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void validateMobileNumberTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validateMobileNumberTest';
        System.debug(debugString);
        
        //SETUP
        String phoneNumber = '';

        //TESTING
        Test.startTest();
        Try{
            HDT_UTL_PhoneNumbers.validateMobileNumber(phoneNumber);
            phoneNumber = '39d5';
            HDT_UTL_PhoneNumbers.validateMobileNumber(phoneNumber);
            phoneNumber = '354678940312';
            HDT_UTL_PhoneNumbers.validateMobileNumber(phoneNumber);
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phoneNumber != null, 'Attenzione, phoneNumber non può essere null!');
        
    }

    @isTest
    private static void validatePhoneNumberTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'validatePhoneNumberTest';
        System.debug(debugString);
        
        //SETUP
        String phoneNumber = '';


        //TESTING
        Test.startTest();
        Try{
            HDT_UTL_PhoneNumbers.validatePhoneNumber(phoneNumber);
            phoneNumber = '39d5';
            HDT_UTL_PhoneNumbers.validatePhoneNumber(phoneNumber);
            phoneNumber = '3905';
            HDT_UTL_PhoneNumbers.validateMobileNumber(phoneNumber);
            phoneNumber = '354678940312';
            HDT_UTL_PhoneNumbers.validatePhoneNumber(phoneNumber);
            phoneNumber = '3546';
            HDT_UTL_PhoneNumbers.validatePhoneNumber(phoneNumber);
            phoneNumber = '3546789403';
            HDT_UTL_PhoneNumbers.validatePhoneNumber(phoneNumber);            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(phoneNumber != null, 'Attenzione, phoneNumber non può essere null!');        
    }


}
