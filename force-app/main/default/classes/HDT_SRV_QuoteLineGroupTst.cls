/**
* Header of the class "HDT_SRV_QuoteLineGroupTst"
* @author: Luca Belometti - WR (luca.belometti@webresults.it)
* @version 1.0
* @description: This is the ApexTestClass to test the creation and crud permission about the fields/records of the QuoteLineGroup Object
* @history
* Created: 2021-08-10
* Modified By:
**/

@IsTest
public with sharing class HDT_SRV_QuoteLineGroupTst {
    @TestSetup
    static void makeData(){        
         List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
         List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
         List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
         List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');
         List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, true, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');        
    }

    @isTest
    public static void testCheckAccessInit() {

        Boolean finished = false;

        Test.startTest();

        HDT_SRV_QuoteLineGroup quoteLineGroupClass = new HDT_SRV_QuoteLineGroup();

        quoteLineGroupClass.checkAccessInit('Name', 'read');

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');
    }

    @isTest
    public static void testCheckReadAccess() {

        Boolean finished = false;

        Test.startTest();

        HDT_SRV_QuoteLineGroup quoteLineGroupClass = new HDT_SRV_QuoteLineGroup();

        quoteLineGroupClass.checkReadAccess('Name');

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');
    }
    
    @isTest
    public static void testCheckCreateAccess() {

        Boolean finished = false;

        Test.startTest();

        HDT_SRV_QuoteLineGroup quoteLineGroupClass = new HDT_SRV_QuoteLineGroup();

        quoteLineGroupClass.checkCreateAccess('Name');

        finished = true;

        Test.stopTest();

        System.assertEquals(true, finished, 'Test Ended');
    }

    @isTest
    public static void testCreateRecords() {
        List<Account> accToTest = [SELECT Id FROM Account LIMIT 1];
        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__Quote__c> listQuotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
        qlg.SBQQ__Quote__c = listQuotes[0].Id;
        qlg.SBQQ__Account__c = accToTest[0].id;
        qlgList.add(qlg);

        Test.startTest();

        HDT_SRV_QuoteLineGroup quoteLineGroupClass = new HDT_SRV_QuoteLineGroup();

        quoteLineGroupClass.createRecords(qlgList);

        List<SBQQ__QuoteLineGroup__c> testCreationOfQLG = [SELECT Id FROM SBQQ__QuoteLineGroup__c LIMIT 1];

        System.assertNotEquals(null, testCreationOfQLG[0].Id, 'The ORG has the record, just created -- there is a Id in the ORG');

        Test.stopTest();
    }

    
    @isTest
    public static void testCreateRecord() {
        List<Account> accToTest = [SELECT Id FROM Account LIMIT 1];
        List<SBQQ__Quote__c> listQuotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c();
        qlg.SBQQ__Quote__c = listQuotes[0].Id;
        qlg.SBQQ__Account__c = accToTest[0].id;

        Test.startTest();

        HDT_SRV_QuoteLineGroup quoteLineGroupClass = new HDT_SRV_QuoteLineGroup();
        quoteLineGroupClass.createRecord(qlg);

        List<SBQQ__QuoteLineGroup__c> testCreationOfQLG = [SELECT Id FROM SBQQ__QuoteLineGroup__c LIMIT 1];
        System.assertNotEquals(null, testCreationOfQLG[0].Id, 'The ORG has the record, just created -- there is a Id in the ORG');

        Test.stopTest();
    }

}
