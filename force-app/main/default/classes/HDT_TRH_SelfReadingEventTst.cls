@isTest
public with sharing class HDT_TRH_SelfReadingEventTst {
    
    //DEBUG
    
    
    //DATA
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, true, acc[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    //TESTS
    
    //COVERAGE INCREASE TEST
    @isTest
    private static void coverageIncreaseTest() {
        
        //SETUP
        mySetup();
        
        Case myCaseForHeroku = [SELECT Id FROM Case];
        
        
        //PREPARING EVENT
        HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
        event.SerializedCase__c = JSON.serialize(myCaseForHeroku);
        
        //TESTING
        
        
        //RETRIEVING DATA
        
        
        //ASSERTS
        
        
    }
}
