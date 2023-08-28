@isTest
public with sharing class HDT_BA_AlignSapOfferCodeTableTst {
    @TestSetup
    static void makeData(){
        List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        for(Product2 prod : products){
            prod.ProductCode = 'ACANTINC00';
            prod.Version__c = 'V1';
            prod.Family = 'Offerta Commerciale';
        }
        insert products;

        OfferCode32Admin__c offerCodeAdmin = new OfferCode32Admin__c();
        offerCodeAdmin.OfferCode32__c = 'TESTTESTETSSTESTESTESTEETSTEST98';
        offerCodeAdmin.OfferProductCode__c = 'ACANTINC00';
        offerCodeAdmin.OfferProductVersion__c = '	V1';
        offerCodeAdmin.CodT0__c = 'Y';
        offerCodeAdmin.EffectiveDate__c = 10;
        offerCodeAdmin.Service__c = 'G';
        offerCodeAdmin.Company__c = '2060';
        offerCodeAdmin.MarketType__c = 'Libero';
        offerCodeAdmin.Exported__c = false;
        insert offerCodeAdmin;
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('AllignSapOfferCode', 'Callout:MulesoftBasePath', 'method', 'testUser');
    }

    @isTest
    static void executeBatch(){
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();       
        Database.executeBatch(new HDT_BA_AlignSapOfferCodeTable(), Integer.valueOf(Label.HDT_AlignOfferCodeSapTableMaxItem));
        Test.stopTest();
        List<OfferCode32Admin__c> listOfOfferCodeAdmin = new List<OfferCode32Admin__c>([SELECT Id FROM OfferCode32Admin__c WHERE Exported__c =: true]);
        System.assertEquals(false, listOfOfferCodeAdmin.isEmpty());

    }
    @isTest
    static void executeCronBatch(){
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Scheduling', chron, new HDT_BA_AlignSapOfferCodeTable());
        Test.stopTest();
        List<OfferCode32Admin__c> listOfOfferCodeAdmin = new List<OfferCode32Admin__c>([SELECT Id FROM OfferCode32Admin__c WHERE Exported__c =: false]);
        System.assertEquals(false, listOfOfferCodeAdmin.isEmpty());

    }
}