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
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Account testAccount = [SELECT Id FROM Account];
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
