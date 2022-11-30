/**
 * @description       : 
 * @author            : Andrei Necsulesc
 * @group             : 
 * @last modified on  : 11-17-2022
 * @last modified by  : Andrei Necsulescu
**/
@isTest
public with sharing class HDT_UTL_LandRegistryTst {

    @TestSetup
    static void setup(){
        
        Id landRegistryRecordtypeId = Schema.SObjectType.LandRegistry__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DatiCatastali_TARI').getRecordTypeId();
        ServicePoint__c sp = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];

        HDT_UTL_DataFactoryTst.createCityTechnicalData(1, true, 'Roma', Date.today(), Date.today().addDays(31), Date.today().addDays(365), 'Error message');

        HDT_UTL_DataFactoryTst.createLandRegistries(new List<String> {'Roma', 'Milano'}, landRegistryRecordtypeId, sp, true);

        HDT_UTL_DataFactoryTst.createCase(1, true, null, null, sp.Id, null, null);
        
    }
    
    
    @isTest 
    public static void getLandRegistryByServicePointTest(){

        Case cs = [SELECT Id, ServicePoint__c FROM Case LIMIT 1];

        Test.startTest();
        LandRegistry__c land = HDT_UTL_LandRegistry.retrieveLandRegistryTable(cs.Id, null, cs.ServicePoint__c).get(0);
        System.assertEquals(land.LegalCity__c, 'Roma', 'The correct LandRegistry__c was not retrieved');
        Test.stopTest();

    }

    @isTest 
    public static void getCadastralCategoriesTest(){

        CadastralCategories__c cadCategories = new CadastralCategories__c();
        cadCategories.Description__c = 'Test';
        insert cadCategories;

        Test.startTest();
        CadastralCategories__c categories = HDT_UTL_LandRegistry.getCadastralCategories()[0];
        System.assertEquals(categories.Description__c, 'Test', 'The correct CadastralCategories__c was not retrieved');
        Test.stopTest();

    }


    @isTest 
    public static void getCitiesTest(){

        Test.startTest();
        CityTechnicalData__c cities = HDT_UTL_LandRegistry.getCities()[0];
        System.assertEquals(cities.CadastralCity__c, 'Roma', 'The CityTechnicalData__c was not retrieved correctly');
        Test.stopTest();

    }

    @IsTest
    static void getVistaDatiCatastaliTest(){
        
        ServicePoint__c sp = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];

        Test.startTest();

            Object res = HDT_UTL_LandRegistry.getVistaDatiCatastali(sp.Id);
            System.assertEquals(res != null, true, 'The object returned by getVistaDatiCatastali is null');

        Test.stopTest();
        
    }

    @IsTest
    static void getVistaDatiCatastaliResponseTest(){
        
        ServicePoint__c sp = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];

        HttpResponse response = new HttpResponse();
        response.setStatus('success');
        response.setStatusCode(202);
        response.setBody(JSON.serialize(new HDT_WS_VistaDatiCatastaliResponse()));

        Test.setContinuationResponse('TestContinuation', response);

        Test.startTest();

            Object res = HDT_UTL_LandRegistry.getVistaDatiCatastaliResponse(new List<String> {'TestContinuation'}, null);
            System.assertEquals(res != null, true, 'The object returned by getVistaDatiCatastaliResponse is null');

        Test.stopTest();
        
    }
}