@isTest
public with sharing class HDT_LC_CaseDocumentValidationTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_LC_CaseDocumentValidationTstTst';
    
    
    //TEST SETUP
    @TestSetup
    static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
    }
    
    //TESTS
    
    @isTest
    private static void isValidPhaseTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'isValidPhaseTest';
        System.debug(debugString);
        
        //TESTING
        Case myCase = [SELECT Id FROM Case];
        Boolean result = HDT_LC_CaseDocumentValidation.isValidPhase(myCase.Id);
        
        //ASSERTS
        System.assert(result);
        
    }
    
}
