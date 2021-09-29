@isTest
public with sharing class HDT_WS_SelfReadingsTst {
    
    //DEBUG
    
    
    //DATA
    
    
    //TEST SETUP
    private static void mySetup(){
        
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> bpf = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, acc[0].Id);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, acc[0].Id, 'Bozza');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseAutolettura(1, true, acc[0].id, contactList[0].Id, servPoint.Id, contractList[0].id, ordList[0].id);
        HDT_UTL_DataFactoryTst.pClickCasePhase();
    }
    
    
    //TESTS
    
    //
    @isTest
    private static void doPostTest() {
        
        //SETUP
        mySetup();
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData reading = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsData();
        
        
        HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest srr = new HDT_WRP_SelfReadings.HDT_WRP_SelfReadingsRequest();
        srr.commodity = '';
        srr.contractCode = '';
        srr.readings = reading;
        
        
        
        //REST CONTEXT
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(JSON.serialize(srr));
        
        RestContext.request =req;
        RestContext.response = res;
        
        
        
        //TESTING
        HDT_WS_SelfReadings.doPost();
        
        //ASSERTS
        
    }
    
    
    ///THROW 1
    
    
    
    ///THROW 2
    
    
    
    ///THROW 3
    
    
    
    
}
