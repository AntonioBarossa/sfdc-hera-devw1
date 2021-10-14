@isTest
public with sharing class HDT_UTL_ReimbursementTst 
{    
    @TestSetup
    static void setup()
    {
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        AccountContactRelation accountContactRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id,contactList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        List<DocumentSelected__c> documents = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id,billingProfileList[0].ContractAccountCode__c);
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', rtId, rtName,'A','','','');
    }

    @isTest
    static void reimbursementChecksTst()
    {
        List<HDT_UTL_Reimbursement.HDT_UTL_FlowOutputs> outputs = new List<HDT_UTL_Reimbursement.HDT_UTL_FlowOutputs>();
        List<HDT_UTL_Reimbursement.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Reimbursement.HDT_UTL_FlowInputs>();
        HDT_UTL_Reimbursement.HDT_UTL_FlowInputs input = new HDT_UTL_Reimbursement.HDT_UTL_FlowInputs();
        Account testAccount = [SELECT Id, CustomerCode__c FROM Account LIMIT 1];
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        input.recordId = testCase.Id;
        input.customerCode = testAccount.CustomerCode__c;
        inputs.add(input);
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        Test.startTest();
        outputs = HDT_UTL_Reimbursement.reimbursementChecks(inputs);
        Test.stopTest();
        System.assertEquals(true, outputs[0].documentCheck,'');
        System.assertEquals(false, outputs[0].accountBalanceCheck,'');

    }
}
