@isTest
public with sharing class HDT_UTL_CaseApprovalProcessTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_UTL_CaseApprovalProcessTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    
    //submitForApproval
    @isTest
    private static void submitForApprovalTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'submitForApprovalTest';
        System.debug(debugString);
        
        //SETUP
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        //TESTING
        Test.startTest();
        try{
            HDT_UTL_CaseApprovalProcess.submitForApproval(caseList);
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        //ASSERTS
        System.assert(caseList != null, 'Attenzione, caseList non può essere null!');
        
    }


}

