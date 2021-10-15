@isTest
public with sharing class HDT_LC_GenericTableTst {

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
    static void getDataTst()
    {
        Account tstAccount = [SELECT Id FROM Account LIMIT 1];
        Case tstCase = [SELECT Id, Type FROM Case LIMIT 1];
        List<Object> columns = new List<Object>();
        List<Object> rowData = new List<Object>();
        tstCase.Type = 'Riattivazione Fornitura';
        update tstCase;
        String output = '';
        Test.startTest();
        output = HDT_LC_GenericTable.getData('Prova', 'AccountId', tstAccount.Id);
        Test.stopTest();
        Map<String, Object> tstOutput = (Map<String,Object>) JSON.deserializeUntyped(output);
        columns.add(tstOutput.get('columns'));
        rowData.add(tstOutput.get('rowData'));
        System.Assert(columns.size() > 0, 'getData did not work correctly');
        System.Assert(rowData.size() > 0, 'getData did not work correctly');
    } 

}
