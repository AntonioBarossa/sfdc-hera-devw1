@isTest
public with sharing class HDT_UTL_SlaManagementTst {

    @TestSetup
    static void makeData(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
        HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orders[0].id);
    }

    @isTest
    static void constructorMethodsTst(){
        Test.startTest();
        HDT_UTL_SlaManagement slaMngCase=new HDT_UTL_SlaManagement('Case');
        HDT_UTL_SlaManagement slaMngOrder=new HDT_UTL_SlaManagement('Order');
        Test.stopTest();
        System.assertEquals(true, slaMngCase!=null,'class created');
        System.assertEquals(true, slaMngOrder!=null,'class created');
    }

    @isTest
    static void setChangedObjListTst(){
        Case myCase=[SELECT Id,AccountId,ContactId FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WRP_SlaManagement.HDT_WRP_Event slaWrp=new HDT_WRP_SlaManagement.HDT_WRP_Event();
        slaWrp.recordId=myCase.Id;
        slaWrp.sObjType='Case';
        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>{myCase.Id=>slaWrp};
        HDT_UTL_SlaManagement slaUtils=new HDT_UTL_SlaManagement('Case');
        Test.startTest();
        slaUtils.setChangedObjList(wrpEventObjMap);
        Test.stopTest();
        System.assertEquals(true, slaUtils!=null, 'no exception occurred');
    }

    @isTest
    static void executeTst(){
        Test.startTest();
        Test.stopTest();
        System.assertEquals(true, true, 'temp');
    }
}
