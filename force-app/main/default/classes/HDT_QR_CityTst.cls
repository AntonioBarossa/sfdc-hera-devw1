/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 02/09/2021
 * @description HDT_QR_City Test Class
 * @history Lucas da Silva Fernandes – 02/09/2021 – Created Class
 */

@isTest
public with sharing class HDT_QR_CityTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
        // System Administrator User
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;
        insert internalUser;

        System.runAs(internalUser) {

            List<City__c> cities = HDT_UTL_DataFactoryTst.createCity(1, false);
            cities[0].ServiceEle__c = true;
            cities[0].ServiceGas__c = true;
            cities[0].SDV__c = 'sdvTest';
            insert cities;
        }
    }

    @isTest
    public static void testGetCityCode() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            City__c ct = [SELECT Id, Name, BelfioreCode__c FROM City__c WHERE Name = 'Roma'];

            String testCity = HDT_QR_City.getCityCode(ct.Name);

            System.assertEquals(ct.BelfioreCode__c, testCity, 'City successfully queried');
            System.assertNotEquals('', testCity, 'City query failed');

            testCity = HDT_QR_City.getCityCode('');

            System.assertEquals('', testCity, 'City query empty');
            System.assertNotEquals('Bt0', testCity, 'City query populated');

            Test.stopTest();
        }
    }

    @isTest
    public static void testGetCitySDVEle() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            City__c ct = [SELECT Id, Name, BelfioreCode__c, SDV__c FROM City__c WHERE Name = 'Roma'];

            String testCity = HDT_QR_City.getCitySDVEle(ct.Name);

            System.assertEquals(ct.SDV__c, testCity, 'City successfully queried');
            System.assertNotEquals('', testCity, 'City query failed');

            testCity = HDT_QR_City.getCitySDVEle('');

            System.assertEquals('', testCity, 'City query empty');
            System.assertNotEquals('sdvTest', testCity, 'City query populated');
            
            Test.stopTest();
        }
    }

    @isTest
    public static void testGetCitySDVList() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            List<City__c> ct = [SELECT Id, Name, BelfioreCode__c, SDV__c FROM City__c WHERE Name = 'Roma'];

            List<String> cityName = new List<String>();

            for (Integer i=0; i<ct.size(); i++){

                String city = String.valueOf(ct[i].Name);
                cityName.add(city);
            }

            List<City__c> citiesList = HDT_QR_City.getCitySDVList(cityName);

            System.assertEquals(ct[0].SDV__c, citiesList[0].SDV__c, 'City successfully queried');
            System.assertNotEquals('', citiesList[0].SDV__c, 'City query failed');

            List<String> empty = new List<String>();

            List<City__c> citiesList2 = HDT_QR_City.getCitySDVList(empty);

            System.assertEquals(true, citiesList2.isEmpty(), 'City query empty');
            System.assertNotEquals(false, citiesList2.isEmpty(), 'City query populated');
            
            Test.stopTest();
        }
    }

    @isTest
    public static void testGetCitySDVGas() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            City__c ct = [SELECT Id, Name, SDV__c FROM City__c WHERE Name = 'Roma'];

            String testCity = HDT_QR_City.getCitySDVGas(ct.Name);

            System.assertEquals(ct.SDV__c, testCity, 'City successfully queried');
            System.assertNotEquals('', testCity, 'City query failed');

            testCity = HDT_QR_City.getCitySDVGas('');

            System.assertEquals('', testCity, 'City query empty');
            System.assertNotEquals('sdvTest', testCity, 'City query populated');
            
            Test.stopTest();
        }
    }

    @isTest
    public static void testGetCityFromCode() {

        User u=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];
    
        System.runAs(u){

            Test.startTest();

            List<City__c> ct = [SELECT Id, Name, BelfioreCode__c, SDV__c FROM City__c WHERE Name = 'Roma'];

            List<String> cityCode = new List<String>();

            for (Integer i=0; i<ct.size(); i++){

                String city = String.valueOf(ct[i].BelfioreCode__c);
                cityCode.add(city);
            }

            Map<String,String> mapCities = HDT_QR_City.getCityFromCode(cityCode);

            System.assertEquals(false, mapCities.isEmpty(), 'City query empty');
            System.assertNotEquals(true, mapCities.isEmpty(), 'City query populated');
            
            Test.stopTest();
        }
    }
}
