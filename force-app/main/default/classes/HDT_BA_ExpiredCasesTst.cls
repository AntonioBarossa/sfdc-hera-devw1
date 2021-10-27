@isTest
public with sharing class HDT_BA_ExpiredCasesTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_BA_ExpiredCasesTst';
    
    
    //DATA
    
    
    
    //TEST SETUP
    private static void mySetup(){
        
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        for(Case c : caseList){
            c.DocusignExpirationDate__c = Date.today().addDays(5);
            c.RecordTypeId = recTypeId;
            //c.Contact__c = conList[0].Id;
        }
        insert ordList;
        
    }
    
    
    //TESTS
    
    @isTest
    private static void myBatchTest() {

    }
    
}
