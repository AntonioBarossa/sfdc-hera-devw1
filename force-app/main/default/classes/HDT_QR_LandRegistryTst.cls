/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 11-17-2022
 * @last modified by  : Andrei Necsulescu
**/
@isTest
public with sharing class HDT_QR_LandRegistryTst {

    @TestSetup
    static void setup(){
        
        Id landRegistryRecordtypePratica = Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DatiCatastali_PraticaTARI').getRecordTypeId();
        Id landRegistryRecordtypeId = Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DatiCatastali_TARI').getRecordTypeId();

        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME')[0];
        Order ord = HDT_UTL_DataFactoryTst.createOrder(1, true, acc.Id, 'Bozza')[0];
        Case cas = HDT_UTL_DataFactoryTst.createCase(1, true, acc.Id, null, null, null, ord.Id)[0];

        ServicePoint__c sp = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];

        List<LandRegistry__c> landRegistries = HDT_UTL_DataFactoryTst.createLandRegistries(new List<String> {'Roma', 'Roma'}, landRegistryRecordtypePratica, sp, false);
        landRegistries[0].Order__c = ord.Id;
        landRegistries[0].Case__c = cas.Id;

        landRegistries[1].Order__c = ord.Id;
        landRegistries[1].Case__c = cas.Id;
        landRegistries[1].RecordTypeId = landRegistryRecordtypeId;

        insert landRegistries;
    }
    
    @isTest 
    public static void getPraticaTARILandRegistryByOrderIdsTest(){

        Order ord = [SELECT Id FROM Order LIMIT 1];

        Test.startTest();
            LandRegistry__c land = (new HDT_QR_LandRegistry()).getPraticaTARILandRegistryByOrderIds(new List<Id> {ord.Id})[0];
            System.assertEquals(land.LegalCity__c, 'Roma', 'The correct LandRegistry__c was not retrieved');
        Test.stopTest();

    }

    @isTest
    public static void getPraticaTARILandRegistryByCaseIdsTest(){

        Case cas = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
            LandRegistry__c land = (new HDT_QR_LandRegistry()).getPraticaTARILandRegistryByCaseIds(new List<Id> {cas.Id})[0];
            System.assertEquals(land.LegalCity__c, 'Roma', 'The correct LandRegistry__c was not retrieved');
        Test.stopTest();

    }

    @isTest 
    public static void getTARILandRegistryByServicePointIdsTest(){

        ServicePoint__c sp = [SELECT Id FROM ServicePoint__c LIMIT 1];

        Test.startTest();
            LandRegistry__c land = (new HDT_QR_LandRegistry()).getTARILandRegistryByServicePointIds(new List<Id> {sp.Id})[0];
            System.assertEquals(land.LegalCity__c, 'Roma', 'The correct LandRegistry__c was not retrieved');
        Test.stopTest();

    }
    
}
