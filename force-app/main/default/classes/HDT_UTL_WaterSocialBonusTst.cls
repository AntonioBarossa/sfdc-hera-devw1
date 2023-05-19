@isTest
public with sharing class HDT_UTL_WaterSocialBonusTst {
    @TestSetup
    static void setup(){
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        acctList[0].CustomerCode__c = '1003616210';
    }

    @IsTest
    static void setBodyRequest(){
        Test.startTest();
        Type t = Type.forName('HDT_UTL_WaterSocialBonus');
        HDT_SRV_AccountDataEnrichmentSupport support = (HDT_SRV_AccountDataEnrichmentSupport)t.newInstance();
        List<Account> acctList = [SELECT Id,CustomerCode__c,FiscalCode__c from Account limit 1];
        List<HDT_AccountDataEnrichment__mdt> enrichmentbMetadataList;
        enrichmentbMetadataList = HDT_QR_AccountDataEnrichment.getAccountDataEnrichment(enrichmentbMetadataList, 'bonusSocialeIdrico');
        support.setMetadata(enrichmentbMetadataList);
        support.setRecordIds(acctList[0].Id, null);
        support.setBodyRequest();
        Test.stopTest();
    }
}