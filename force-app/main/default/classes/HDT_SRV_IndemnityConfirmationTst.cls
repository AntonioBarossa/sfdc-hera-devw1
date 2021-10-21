@isTest
public with sharing class HDT_SRV_IndemnityConfirmationTst {
    
    //DEBUG
    public static final String TEST_NAME = 'HDT_SRV_IndemnityConfirmationTst';
    
    //DATA
    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    
    
    //TEST SETUP
    private static void mySetup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
    }
    
    
    //TESTS
    @isTest
    private static void checkIndemnityConfirmationTest() {
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'checkIndemnityConfirmationTest';
        System.debug(debugString);
        
        //SETUP
        mySetup();
        
        Account acc = [SELECT Id FROM Account];
        Contact con = [SELECT Id FROM Contact];
        ServicePoint__c srv = [SELECT Id FROM ServicePoint__c];
        Contract contract = [SELECT Id FROM Contract];
        Order ord = [SELECT Id FROM Order];
        
        //MY CASE 1
        Case myCase_1 = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, false, acc.id, con.Id, srv.id, contract.id, ord.id)[0];
        myCase_1.ComplaintType__c = 'Reclamo Scritto';
        myCase_1.FirstLevelComplaintClassification__c = 'Reclamo Scritto';
        myCase_1.SecondLevelComplaintClassification__c = 'Misura';
        myCase_1.IndemnityConfirmed__c = true;
        insert myCase_1;
        
        //MY CASE 2
        Case myCase_2 = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, false, acc.id, con.Id, srv.id, contract.id, ord.id)[0];
        insert myCase_2;
        
        //HDT_UTL_FlowInputs
        HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs input = new HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs();
        input.recordId = myCase_2.Id;
        input.accountId = acc.Id;
        input.servicePointId = srv.Id;
        input.firstLevel = myCase_1.FirstLevelComplaintClassification__c;
        input.secondLevel = myCase_1.SecondLevelComplaintClassification__c;
        
        List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs> inputs;
        inputs = new List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowInputs>{input};
        
        
        //TESTING
        List<HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowOutputs> outputs;
        outputs = HDT_SRV_IndemnityConfirmation.checkIndemnityConfirmation(inputs);
        
        //ASSERTS
        HDT_SRV_IndemnityConfirmation.HDT_UTL_FlowOutputs output = outputs[0];
        System.assert(output.indemnityNotConfirmed);
        
    }
    
}
