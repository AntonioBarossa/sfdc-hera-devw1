/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 15-09-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_QR_LandRegistryTst {
    
    
    @isTest 
    public static void getLandRegistryByServicePointTest(){

        ServicePoint__c sp = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];
        LandRegistry__c land = new LandRegistry__c();
        land.RecordTypeId=Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByName().get('Dati Catastali TARI').getRecordTypeId();
        land.ServicePoint__c=sp.Id;
        land.LegalCity__c ='Roma';
        insert land;

        Test.startTest();
        HDT_UTL_LandRegistry.retrieveLandRegistryTable(new List<Id>{sp.Id});
        System.assertEquals(land.LegalCity__c, 'Roma', 'OK');
        Test.stopTest();

    }

    @isTest 
    public static void getLandRegistryByIdTest(){

        LandRegistry__c land = new LandRegistry__c();
        land.RecordTypeId=Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByName().get('Dati Catastali TARI').getRecordTypeId();
        land.LegalCity__c ='Roma';
        insert land;

        Test.startTest();
        HDT_UTL_LandRegistry.retrieveLandRegistry(new List<Id>{land.Id});
        System.assertEquals(land.LegalCity__c, 'Roma', 'OK');
        Test.stopTest();

    }

    @isTest 
    public static void getCadastralCategoriesTest(){

        CadastralCategories__c cadCategories = new CadastralCategories__c();
        cadCategories.Description__c = 'Test';
        insert cadCategories;

        Test.startTest();
        CadastralCategories__c categories = HDT_UTL_LandRegistry.getCadastralCategories()[0];
        System.assertEquals(categories.Description__c, 'Test', 'OK');
        Test.stopTest();

    }


    @isTest 
    public static void getCitiesTest(){

        CityTechnicalData__c city = new CityTechnicalData__c();
        city.CityCode__c = '00000';
        insert city;

        Test.startTest();
        CityTechnicalData__c cities = HDT_UTL_LandRegistry.getCities()[0];
        System.assertEquals(cities.CityCode__c, '00000', 'OK');
        Test.stopTest();

    }

    
}
