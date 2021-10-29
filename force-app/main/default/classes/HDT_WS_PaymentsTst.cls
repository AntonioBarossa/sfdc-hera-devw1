@isTest
public with sharing class HDT_WS_PaymentsTst {

    @TestSetup
    static void setup(){
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        AccountContactRelation accountContactRel;
        List<Contract> contractListTwo;
        List<Case> caseList;
        List<DocumentSelected__c> documents;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        accountContactRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id,contactList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
        caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        documents = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id,billingProfileList[0].ContractAccountCode__c);
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', rtId, rtName,'A','','','');
    }

    @isTest
    static void executeTst()
    {
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        HDT_WS_Payments paymentsWs = new HDT_WS_Payments();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        testCase.Amount__c = 100;
        testCase.DepositPaymentMode__c = 'Paperless';
        testCase.Type = 'Comunicazione Pagamento';
        update testCase;
        testCase = [SELECT CaseNumber, Type, DepositPaymentMode__c FROM Case LIMIT 1];
        Map<String, Object> args = new Map<String, Object>();
        args.put('transition', null);
        args.put('action', null);
        args.put('sender', testCase);
        //Valutare ciclo su method per testare tutti i vari scenari
        args.put('method', 'HDT_PaymentCommunication');
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        Test.startTest();
        responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) paymentsWs.execute(args);
        Test.stopTest();
        testCase = [SELECT TecnicalPhase__c FROM Case LIMIT 1];
        System.assertEquals(true, responseReturn.success, 'Failure in Response');
        System.assert(testCase.TecnicalPhase__c == null, 'Fase non aggiornata');

    }


}
