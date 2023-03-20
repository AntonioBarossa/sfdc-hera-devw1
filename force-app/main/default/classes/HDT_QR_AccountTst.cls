/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 23/08/2021
 * @description HDT_QR_Account Test Class
 * @history Lucas da Silva Fernandes – 23/08/2021 – Created Class
 */
@isTest
public with sharing class HDT_QR_AccountTst {
    
    private static HDT_QR_Account qrAcc = new HDT_QR_Account();

    @TestSetup
    static void setup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
        accList[0].BillingStreetNumberExtension__c = 'nExt';
        accList[0].BillingCity = 'Torino';
        accList[0].BillingPostalCode = '10123';
        accList[0].BillingCountry = 'Vatican';
        accList[0].BillingStreetCode__c = 'myStreetCode';
        accList[0].BillingCityCode__c = 'TO';
        accList[0].Code__c = 'iddqd';
        insert accList;

        HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'MMS', 'G1 - MMS Persona fisica', 'Famiglie');
        
    }

    @isTest
    public static void testGetRecordById() {

        Test.startTest();

        Account acc = [SELECT Id, Name FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        Account accQrTest = qrAcc.getRecordById(acc.Id, 'Name');

        System.assertEquals(acc.Id, accQRTest.Id, 'Account Id match.');
        System.assertNotEquals(null, accQRTest.Id, 'Account Id does not match.');

        Test.stopTest();
    }

    @isTest
    public static void testgetRecordsById() {
        
        Test.startTest();

        List<Account> acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM'];

        List<String> stId = new List<String>();

        for(Integer i=0; i<acc.size(); i++){

            String st = String.valueOf(acc[i].Id);
            
            System.debug(st);

            stId.add(st);
        }

        List<Account> accList = qrAcc.getRecordsById(stId, 'Id');

        System.assertEquals(stId[0], accList[0].Id, 'Account Id match.');
        System.assertNotEquals(null, accList[0].Id, 'Account Id does not match.');

        Test.stopTest();
    }

    @isTest
    public static void testGetBillingAddressAccount() {

        Test.startTest();

        Account acc = [SELECT Id, BillingPostalCode FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        Account accTest = qrAcc.getBillingAddressAccount(acc.Id);

        System.assertEquals(acc.BillingPostalCode, accTest.BillingPostalCode, 'Billing Address found.');

        System.assertNotEquals(null, accTest.BillingPostalCode, 'Billing Address not found.');

        Test.stopTest();
    }

    @isTest
    public static void testGetAccountByDistributorKey () {

        Test.startTest();

        Account acc = [SELECT Id, Code__c FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        Account accQrTest = qrAcc.getAccountByDistributorKey(acc.Code__c);

        System.assertEquals(acc.Id, accQRTest.Id, 'Account Id match.');
        System.assertNotEquals(null, accQRTest.Id, 'Account Id does not match.');

        Test.stopTest();
    }

    @isTest
    public static void testGetAccountByFiscalCode() {

        Test.startTest();

        Account acc = [SELECT Id, FiscalCode__c FROM Account WHERE CompanyOwner__c = 'MMS' LIMIT 1];

        List<Account> accList = qrAcc.getAccountByFiscalCode(acc.FiscalCode__c);

        System.assertEquals(acc.Id, accList[0].Id, 'Accounts match');

        System.assertNotEquals(null, accList[0].Id, 'Accounts does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetAllAccounts() {

        Test.startTest();

        List<Account> accList = [SELECT Id FROM Account];

        List<Account> accListAll = qrAcc.getAllAccounts();

        System.assertEquals(accList.size(), accListAll.size(), 'Amount of Accounts match');

        System.assertNotEquals(null, accListAll.size(), 'Amount of Accounts do not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetAccountByVat() {

        Test.startTest();

        List<Account> acc = [SELECT Id, VATNumber__c FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        List<Account> accListVat = qrAcc.getAccountByVat(acc[0].VATNumber__c);

        System.assertEquals(acc[0].Id, accListVat[0].Id, 'Accounts match');

        System.assertNotEquals(null, accListVat[0].Id, 'Accounts does not match');

        Test.stopTest();        
    }

    @isTest
    public static void testGetAccountByFiscalCodeAndVat() {

        Test.startTest();

        List<Account> acc = [SELECT Id, VATNumber__c, FiscalCode__c FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        List<Account> accListVat = qrAcc.getAccountByFiscalCodeAndVat(acc[0].FiscalCode__c, acc[0].VATNumber__c);

        System.assertEquals(acc[0].Id, accListVat[0].Id, 'Accounts match');

        System.assertNotEquals(null, accListVat[0].Id, 'Accounts does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetAccountById() {

        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE CompanyOwner__c = 'HERA COMM' LIMIT 1];

        List<Account> accQrTest = qrAcc.getAccountById(acc.Id);

        System.assertEquals(acc.Id, accQRTest[0].Id, 'Account Id match.');
        System.assertNotEquals(null, accQRTest[0].Id, 'Account Id does not match.');

        Test.stopTest();   
    }
}
