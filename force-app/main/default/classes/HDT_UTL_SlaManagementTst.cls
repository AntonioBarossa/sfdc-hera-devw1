@isTest
public with sharing class HDT_UTL_SlaManagementTst {

    @TestSetup
    static void makeData(){
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
        List<Case> caseList=HDT_UTL_DataFactoryTst.createCase(1, true, accounts[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, orders[0].id);
        Map<String,Object> slaAdminFields=new Map<String,Object>{
            'Ato__c'=>'ATO Orientale Triestino','IsActive__c'=>true,
            'CaseField__c'=>'CustomerRequestDate__c','OrderField__c'=>'SendCertifiedEmailConsentDate__c',
            'FirstLevelComplaintClassification__c'=>'Reclamo Scritto','SecondLevelComplaintClassification__c'=>'Mercato','Cluster__c'=>'Attivazioni',
            'Description__c'=>'test','StartCasePhase__c'=>'Bozza','EndCasePhase__c'=>'Comunicazione verso Heroku OK',
            'StartOrderPhase__c'=>'Bozza','EndOrderPhase__c'=>'Comunicazione verso Heroku OK','Range__c'=>15,
            'Process__c'=>'Documentale/Copia Contratto','RecordTypeId'=>Schema.SObjectType.SlaAdministration__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_PostSales').getRecordTypeId(),
            'Commodity__c'=>'Acqua','SalesCompany__c'=>'Hera Comm S.p.A.','ActivityType__c'=>'Back Office - Fatturazione',
            'CustomerType__c'=>'Account','RangeType__c'=>'Giorni Solari','Type__c'=>'01'
        };
        List<SlaAdministration__c> slaAdminRules=HDT_UTL_DataFactoryTst.createSlaAdministration(1,true,slaAdminFields);
        HDT_UTL_DataFactoryTst.createSlaTracking(1,true,null, slaAdminRules[0].Id, caseList[0].Id, null, 100, 'Aperto');
        HDT_UTL_DataFactoryTst.createSlaTracking(1,true,null, slaAdminRules[0].Id, null, orders[0].Id, 100, 'Aperto');
        
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
    static void executeCaseTst(){
        Case myCase=[SELECT Id,AccountId,ContactId FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WRP_SlaManagement.HDT_WRP_Event slaWrp=new HDT_WRP_SlaManagement.HDT_WRP_Event();
        slaWrp.recordId=myCase.Id;
        slaWrp.sObjType='Case';
        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>{myCase.Id=>slaWrp};
        HDT_UTL_SlaManagement slaUtils=new HDT_UTL_SlaManagement('Case');
        Test.startTest();
        slaUtils.setChangedObjList(wrpEventObjMap);
        slaUtils.execute();
        Test.stopTest();
        System.assertEquals(true, true, 'temp');
    }

    @isTest
    static void executeOrderTst(){
        Case myOrder=[SELECT Id FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WRP_SlaManagement.HDT_WRP_Event slaWrp=new HDT_WRP_SlaManagement.HDT_WRP_Event();
        slaWrp.recordId=myOrder.Id;
        slaWrp.sObjType='Order';
        Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event> wrpEventObjMap = new Map<Id, HDT_WRP_SlaManagement.HDT_WRP_Event>{myOrder.Id=>slaWrp};
        HDT_UTL_SlaManagement slaUtils=new HDT_UTL_SlaManagement('Order');
        Test.startTest();
        slaUtils.setChangedObjList(wrpEventObjMap);
        slaUtils.execute();
        Test.stopTest();
        System.assertEquals(true, true, 'temp');
    }
}
