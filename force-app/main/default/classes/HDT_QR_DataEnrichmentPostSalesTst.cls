/**
* @author Elvin Iluca
* @date 12/12/2022
* @description Test Class for HDT_QR_DataEnrichmentPostSales.cls
* @history Elvin Iluca – 12/12/2022 – Created class
*/

@isTest
public with sharing class HDT_QR_DataEnrichmentPostSalesTst {
     /**​
    * @author Elvin Iluca
    * @date 12/12/2022
    * @description HDT_QR_DataEnrichmentPostSalesTst – Test Class for HDT_QR_DataEnrichmentPostSales.cls
    */

    @TestSetup
	static void setup(){
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false, accList[0].Id);
        billingProfileList[0].InvoicingStreetName__c = 'Roma';
        billingProfileList[0].InvoicingStreetNumber__c = '15';
        billingProfileList[0].InvoicingStreetNumberExtension__c = '20100 ITALIA';
        billingProfileList[0].InvoicingCity__c = 'ROMA';
        billingProfileList[0].InvoicingProvince__c = 'RM';
        billingProfileList[0].InvoicingPostalCode__c = '10190';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';
        billingProfileList[0].ContractAccountCode__c = '200008867681';
        insert billingProfileList;
        //List<Contract> createContract(Integer amount, Boolean doInsert, Id accId){
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accList[0].Id);
        contractList[0].SAPContractCode__c = '301191347';
        insert contractList;
        //List<ServicePoint__c> createServicePoint(Integer amount, Boolean doInsert){
        HDT_UTL_DataFactoryTst.createServicePoint(1,true);

    }
    
    @isTest
    static void getTranscodeConfig(){
        List<HDT_DataEnrichmentTransocode__mdt> ret;

        HDT_QR_DataEnrichmentPostSales dataEnrichmentPostSales = new HDT_QR_DataEnrichmentPostSales();

        Test.startTest();
        ret = dataEnrichmentPostSales.getTranscodeConfig();
        Test.stopTest();
        System.assertNotEquals(ret.isEmpty(), true, 'Error querying HDT_DataEnrichmentTransocode__mdt');
    }

    @isTest
    static void getBillingProfileIdBySapCode(){
        BillingProfile__c ret;

        HDT_QR_DataEnrichmentPostSales dataEnrichmentPostSales = new HDT_QR_DataEnrichmentPostSales();

        Test.startTest();
        ret = dataEnrichmentPostSales.getBillingProfileIdBySapCode('200008867681');
        Test.stopTest();
        System.assertNotEquals(ret.Id, null, 'Error querying BillingProfile__c');
    }

    @isTest
    static void getBillingProfileInvoiceData(){
        BillingProfile__c ret = [SELECT Id FROM BillingProfile__c WITH SECURITY_ENFORCED LIMIT 1][0];

        HDT_QR_DataEnrichmentPostSales dataEnrichmentPostSales = new HDT_QR_DataEnrichmentPostSales();

        Test.startTest();
        ret = dataEnrichmentPostSales.getBillingProfileInvoiceData(ret.Id);
        Test.stopTest();
        System.assertNotEquals(ret.Id, null, 'Error querying BillingProfile__c');
    }

    @isTest
    static void getServicePointData(){
        ServicePoint__c ret = [SELECT Id FROM ServicePoint__c WITH SECURITY_ENFORCED LIMIT 1][0];

        HDT_QR_DataEnrichmentPostSales dataEnrichmentPostSales = new HDT_QR_DataEnrichmentPostSales();

        Test.startTest();
        ret = dataEnrichmentPostSales.getServicePointData(ret.Id);
        Test.stopTest();
        System.assertNotEquals(ret.Id, null, 'Error querying ServicePoint__c');
    }
   
    @isTest
    static void getContractData(){
        Contract ret ;

        HDT_QR_DataEnrichmentPostSales dataEnrichmentPostSales = new HDT_QR_DataEnrichmentPostSales();

        Test.startTest();
        ret = dataEnrichmentPostSales.getContractData('301191347');
        Test.stopTest();
        System.assertNotEquals(ret.Id, null, 'Error querying Contract');
    }
}
