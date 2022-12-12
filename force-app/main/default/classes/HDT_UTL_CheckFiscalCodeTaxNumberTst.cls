/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 29/07/2021
* @description HDT_UTL_CheckFiscalCodeTaxNumber for Test Classes
* @history Luis Bispo – 29/07/2021 – Created class
*/
@isTest
public with sharing class HDT_UTL_CheckFiscalCodeTaxNumberTst {
    @TestSetup
    static void setup(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        acc[0].fiscalCode__C = 'RSSLCU95T24H501P';
        acc[0].Name = 'LUCA'; 
        acc[0].LastName__c = 'ROSSI';
        acc[0].BirthProvince__c = 'Roma';
        acc[0].Gender__c = 'Maschio';
        acc[0].BirthDate__c= Date.valueOf('1995-12-24');
        acc[1].fiscalCode__C = 'SMTNNA95P51H501V';
        acc[1].Name = 'ANNA'; 
        acc[1].LastName__c = 'SMITH';
        acc[1].BirthProvince__c = 'Roma';
        acc[1].Gender__c = 'Femmina';
        acc[1].BirthDate__c= Date.valueOf('1995-09-11');
        insert acc;

        HDT_UTL_DataFactoryTst.createCity();
    }

    @isTest
    public static void testGetDataFromFiscalCodeDataSucess(){

        Account testAccount = [SELECT id, FiscalCode__c, BirthDate__c FROM Account LIMIT 1];
        Test.startTest();
        System.debug(testAccount);

        Map<String,Object> testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData(testAccount.FiscalCode__c);
        System.assert(testFiscalCodeData.size() != null, 'Error Get Data From Fiscal Code');
        System.assertNotEquals(null, testFiscalCodeData, 'Error Get Data From Fiscal Code');

        Set<String> setFiscalCodes = new Set<String>();
        setFiscalCodes.add(testAccount.FiscalCode__c);
        testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(setFiscalCodes);
        System.assert(testFiscalCodeData.size() != null, 'Error Get Data From Fiscal Code');
        System.assertNotEquals(null, testFiscalCodeData, 'Error Get Data From Fiscal Code');

        Map<String,String> mapFiscalCodes = new Map<String,String>();
        mapFiscalCodes.put(testAccount.FiscalCode__c, testAccount.FiscalCode__c);
        testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(mapFiscalCodes);
        System.assert(testFiscalCodeData.size() != null, 'Error Get Data From Fiscal Code');
        System.assertNotEquals(null, testFiscalCodeData, 'Error Get Data From Fiscal Code');
        Test.stopTest();
    }
    @isTest
    public static void testGetDataFromFiscalCodeDataSucessFemale(){

        Account testAccount = [SELECT id, FiscalCode__c, BirthDate__c FROM Account Where Name = 'ANNA' LIMIT 1];
        Test.startTest();
        System.debug(testAccount);

        Map<String,Object> testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData(testAccount.FiscalCode__c);
        System.assert(testFiscalCodeData.size() != null, 'Error Get Data From Fiscal Code');
        System.assertNotEquals(null, testFiscalCodeData, 'Error Get Data From Fiscal Code');

        Set<String> setFiscalCodes = new Set<String>();
        setFiscalCodes.add(testAccount.FiscalCode__c);
        testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(setFiscalCodes);
        System.assert(testFiscalCodeData.size() != null, 'Error Get Data From Fiscal Code');
        System.assertNotEquals(null, testFiscalCodeData, 'Error Get Data From Fiscal Code');

        Map<String,String> mapFiscalCodes = new Map<String,String>();
        mapFiscalCodes.put(testAccount.FiscalCode__c, testAccount.FiscalCode__c);
        testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(mapFiscalCodes);
        System.assert(testFiscalCodeData.size() != null, 'Error Get Data From Fiscal Code');
        System.assertNotEquals(null, testFiscalCodeData, 'Error Get Data From Fiscal Code');
        Test.stopTest();
    }

    @isTest
    public static void testMatchEstimatedFCodeKO(){

        Account testAccount = [SELECT id, FiscalCode__c, Name, LastName__c, BirthDate__c, BirthProvince__c, Gender__c FROM Account LIMIT 1];
        Test.startTest();
        Map<String, String> infoData = new Map<String, String>();
        infoData.put('lastName'     , testAccount.LastName__c);
        infoData.put('firstName'    , testAccount.Name);
        infoData.put('birthDate'    , '1995-12-20');
        infoData.put('birthPlace'   , testAccount.BirthProvince__c);
        infoData.put('gender'       , testAccount.Gender__c);

        System.assertEquals(false, HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedFCode(infoData,testAccount.FiscalCode__c),'codice fiscale valido');
        Test.stopTest();
    }

    @isTest
    public static void testMatchSetEstimatedFiscalCodeKo(){

        Account testAccount = [SELECT id, FiscalCode__c, Name, LastName__c, BirthDate__c, BirthProvince__c, Gender__c FROM Account LIMIT 1];
        Test.startTest();
        Map<String, String> infoData = new Map<String, String>();
        infoData.put('lastName'     , testAccount.LastName__c);
        infoData.put('firstName'    , testAccount.Name);
        infoData.put('birthDate'    , '1995-12-20');
        infoData.put('birthPlace'   , testAccount.BirthProvince__c);
        infoData.put('gender'       , testAccount.Gender__c);

        System.assertEquals(false, HDT_UTL_CheckFiscalCodeTaxNumber.matchEstimatedSetFiscalCode(infoData,testAccount.FiscalCode__c),'codice fiscale valido');
        Test.stopTest();
    }

    @isTest
    public static void testGetDataFromFiscalCodeDataFail(){
        Map<String,Object> testFiscalCodeData = new Map<String,Object>();
        Test.startTest();
        try {
            testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData('Test Fail');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        System.assert(testFiscalCodeData.size() != null, 'Data From FiscalCode Success');
        System.assertNotEquals(null, testFiscalCodeData, 'Data From FiscalCode Success');

        Test.stopTest();
    }

    @isTest
    public static void testGetDataFromFiscalCodeSucess(){
        List<Account> testAccount = [SELECT id, FiscalCode__c FROM Account];
        Map<String,String> fiscalCodes = new Map<String,String>();
        for(Account a: testAccount){
           fiscalCodes.put(a.id,a.FiscalCode__c);
        }
        Test.startTest();
        Map<String,Map<String,Object>> testFiscalCode = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(fiscalCodes);
        
        System.assert(testFiscalCode.size() != null, 'Data From FiscalCode Fail');
        System.assertNotEquals(null, testFiscalCode, 'Data From FiscalCode Fail');
        Test.stopTest();
    }
    @isTest
    public static void testGetDataFromFiscalCodeFail(){
        Map<String,String> fiscalCodes = new Map<String,String>();
        Map<String,Map<String,Object>> testFiscalCode = new Map<String,Map<String,Object>>();
        fiscalCodes.put('Test1', 'Test2');
        Test.startTest();
        try {
            testFiscalCode = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(fiscalCodes);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        System.assert(testFiscalCode.size() != null, 'Data From FiscalCode Success');
        System.assertNotEquals(null, testFiscalCode, 'Data From FiscalCode Success');
        Test.stopTest();
    }
    @isTest
    public static void testGetDataFromFiscalCodeCatch(){
        Set<String> fiscalCodes = new Set<String>();
        fiscalCodes.add('Test1');
        fiscalCodes.add('Test2');
        Map<String,Object> testFiscalCode = new Map<String,Object>();

        Test.startTest();
        try {
            testFiscalCode= HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(fiscalCodes);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        System.assert(testFiscalCode.size() != null, 'Data From FiscalCode Success');
        System.assertNotEquals(null, testFiscalCode, 'Data From FiscalCode Success');
    }
    @isTest
    public static void getBirthDayFromCodeTst()
    {
        String testCode = 'MRCMRC80A41H501Y';
        Test.startTest();
            Date result = HDT_UTL_CheckFiscalCodeTaxNumber.getBirthDayFromCode(testCode);
        Test.stopTest();
        System.assertEquals(Date.newInstance(1980, 1, 1), result, 'Date calcolate correttamente');
    }
}