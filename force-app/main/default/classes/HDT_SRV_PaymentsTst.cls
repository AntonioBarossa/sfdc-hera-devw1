@isTest
public with sharing class HDT_SRV_PaymentsTst {
    
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
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(4, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        List<DocumentSelected__c> documents = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id,billingProfileList[0].ContractAccountCode__c);
        List<DocumentSelected__c> documentsTwo = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[1].Id,billingProfileList[0].ContractAccountCode__c);
        List<DocumentSelected__c> documentsThree = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[2].Id,billingProfileList[0].ContractAccountCode__c);
        List<DocumentSelected__c> documentsFour = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[3].Id,billingProfileList[0].ContractAccountCode__c);
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', rtId, rtName,'A','','','');
    }

    @isTest
    static void createRequestBodyTst()
    {
        HDT_SRV_Payments paymentsSrv = new HDT_SRV_Payments();
        List<Case> testCases = [SELECT Id FROM Case];
        List<String> methods = new List<String>{'HDT_PaymentCommunication','HDT_InstallmentPlans','HDT_Paperless','HDT_ReminderBlock'};
        List<String> bodyResponses = new List<String>();
        for(Case c : testCases){
            c.Amount__c = 100;
            c.DepositPaymentMode__c = 'Paperless';
            c.BlockType__c = 'T1';
        }
        Integer count = 0;
        update testCases;
        Test.startTest();
        for(String method : methods){
            bodyResponses.add(paymentsSrv.createRequestBody(method, testCases[count].Id));
            ++count;
        }
        Test.stopTest();
        count = 0;
        for(String response : bodyResponses){
            if(response != null && String.isNotEmpty(response)){
                ++count;
            }
        }
        System.assertEquals(methods.size(), count,'OK');

    }

}
