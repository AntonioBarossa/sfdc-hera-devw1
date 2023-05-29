@isTest
public with sharing class HDT_UTL_GaaViewTst {
    @TestSetup
    static void setup(){
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        acctList[0].CustomerCode__c = '1003616210';
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
    }
    @IsTest
    static void setBodyRequest(){
        Test.startTest();
        Type t = Type.forName('HDT_UTL_GaaView');
        HDT_SRV_AccountDataEnrichmentSupport support = (HDT_SRV_AccountDataEnrichmentSupport)t.newInstance();
        List<Account> acctList = [SELECT Id,CustomerCode__c from Account limit 1];
        List<ServicePoint__c> spList = [SELECT Id,SAPImplantCode__c FROM ServicePoint__c limit 1];
        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, 'gaaView');
        support.setMetadata(enrichmentbMetadataList);
        support.setRecordIds(acctList[0].Id, spList[0].Id);
        support.setBodyRequest();
        Test.stopTest();
    }
}