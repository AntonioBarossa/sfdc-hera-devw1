@isTest
public with sharing class HDT_SRV_InstallmentPlansTst {
    
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
    }

    @isTest
    static void predefaultInstallmentsValuesTst()
    {
        //1. Se dovesse essere necessario creare un case di Sospensione Fornitura
        //2. Mock per chiamata a vista rate
        //3. Valorizzare metodo di pagamento su BillingProfile
        //4. Creare document Selected nel Setup 
        //5. Valorizzare il campo del Customer Assisted su Account
        //6. Assert sugli ammontare
        Case testCase = [SELECT Id, TotalToPay__c FROM Case LIMIT 1];
        Account testAccount = [SELECT Id, CustomerCode__c FROM Account];
        Test.startTest();
        List<HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs> inputs = new List<HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs>();
        HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs input = new HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs();
        input.recordId = testCase.Id;
        input.accountId = testAccount.Id;
        input.customerCode = testAccount.CustomerCode__c;
        input.totalToPay = testCase.TotalToPay__c;
        inputs.add(input);
        HDT_SRV_InstallmentPlans.predefaultInstallmentsValues(inputs);
        Test.stopTest();
        Case testCaseUpd = [SELECT Id, 
        SuspensionInThePastTwelveMonths__c,
        ExistingInstallmentsPlanNumber__c,
        CAWithOrWithoutSEPA__c,
        ExpirationDate__c,
        AmountToPayInInstallments__c,
        InstallmentAmount__c,
        Amount__c,
        CutomerAssisted__c
        FROM Case
        LIMIT 1];
        System.assertEquals(false, testCaseUpd.SuspensionInThePastTwelveMonths__c);
        System.Assert(testCaseUpd.ExpirationDate__c != null);
        System.Assert(testCaseUpd.AmountToPayInInstallments__c != null);
        System.Assert(testCaseUpd.InstallmentAmount__c != null);
        System.assertEquals(false, testCaseUpd.CutomerAssisted__c);
    }
    @isTest
    static void createRequestBody()
    {

    }
    @isTest
    static void transcodeInstallmentPlanTst()
    {

    }
    @isTest 
    static void evaluateRuleListTst()
    {

    }
    @isTest
    static void formattingErrorMessage()
    {

    }
}
