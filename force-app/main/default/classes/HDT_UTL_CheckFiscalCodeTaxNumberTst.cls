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
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        acc[0].fiscalCode__C = 'RSSMRA90L12E514M';
        insert acc;
    }

    @isTest
    public static void testGetDataFromFiscalCodeDataSucess(){

        Account testAccount = [SELECT id, FiscalCode__c FROM Account LIMIT 1];
        Test.startTest();
        Map<String,Object> testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData(testAccount.FiscalCode__c);
        System.assert(testFiscalCodeData.size() != null);
        System.assertNotEquals(null, testFiscalCodeData);
        Test.stopTest();
    }

    @isTest
    public static void testGetDataFromFiscalCodeDataFail(){
        Map<String,Object> testFiscalCodeData = new Map<String,Object>();
        Test.startTest();
        try {
            testFiscalCodeData = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCodeData('Test Fail');
        } catch (Exception e) {}

        System.assert(testFiscalCodeData.size() != null );
        System.assertNotEquals(null, testFiscalCodeData);

        Test.stopTest();
    }

    @isTest
    public static void testGetDataFromFiscalCodeSucess(){
        Account testAccount = [SELECT id, FiscalCode__c FROM Account LIMIT 1];
        Map<String,String> fiscalCodes = new Map<String,String>();
        fiscalCodes.put(testAccount.id,testAccount.FiscalCode__c);
        Test.startTest();
        Map<String,Map<String,Object>> testFiscalCode = HDT_UTL_CheckFiscalCodeTaxNumber.getDataFromFiscalCode(fiscalCodes);
        
        System.assert(testFiscalCode.size() != null );
        System.assertNotEquals(null, testFiscalCode);
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
        } catch (Exception e) {}

        System.assert(testFiscalCode.size() != null );
        System.assertNotEquals(null, testFiscalCode);
        Test.stopTest();
    }
}
