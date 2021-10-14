/**
* @author Luis Bispo (luis.bispo@engdb.com.br)
* @date 25/08/2021
* @description HDT_QR_SaleServiceItem for Test Classes
* @history Luis Bispo – 25/08/2021 – Created class
*/
@isTest
public with sharing class HDT_QR_SaleServiceItemTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void setup(){
        
		HDT_UTL_DataFactoryTst.pClickInstance();
		HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].id, 'Attiva');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true); 
        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, true, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
    }

    @isTest
    static void testQueryExsistingCityAndType() {
    //  Sale__c & ServicePoint__c & SBQQ__Quote__c & Map<String, String> & Map<String, Decimal>
        Test.startTest();
        Sale__c tSale = [SELECT Id, Agency__c, Campaign__c FROM Sale__c LIMIT 1];
        ServicePoint__c tServicePoint = [SELECT Id, RecordType.DeveloperName, SupplyCity__c, MarketOrigin__c, SupplyProvince__c, MeterType__c, UseCategory__c  FROM ServicePoint__c LIMIT 1];
        SBQQ__Quote__c tQuote = [SELECT Id, Login__c, LoginGroup__c, Role__c, Profile__c, NewClient__c, ResidentDeliveryAddress__c, ConsumptionRangeEE__c, ConsumptionRangeGAS__c, PowerFlow__c, AmendmentAllowed__c FROM SBQQ__Quote__c WHERE AmendmentAllowed__c = false];
        Map<String,String> tMapString = new Map<String,String>();
        Map<String,Decimal> tMapDecimal = new Map<String,Decimal>();

        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
        
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.queryExsistingCityAndType(tSale, tServicePoint, tMapString, tMapDecimal);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
        }
    @isTest
    static void testGetRecordsBySaleId() {
    //  Sale.Id
        Test.startTest();
        Sale__c tSale = [SELECT Id FROM Sale__c LIMIT 1];            
            
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();

        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getRecordsBySaleId(tSale.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetRecordsBySaleIdFilter() {
    //  Sale.Id
        Test.startTest();
        Sale__c tSale = [SELECT Id FROM Sale__c LIMIT 1];            
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getRecordsBySaleIdFilter(tSale.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetSaleByServicePoint() {
    //  ServicePoint__c
        Test.startTest();
        ServicePoint__c tServicePoint = [SELECT Id FROM ServicePoint__c LIMIT 1];
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getSaleByServicePoint(tServicePoint.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty());
        Test.stopTest();
    }
    @isTest
    static void testGetSaleByServicePointFilter() {
    //  ServicePoint__c
        Test.startTest();
        ServicePoint__c tServicePoint = [SELECT Id FROM ServicePoint__c LIMIT 1];
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getSaleByServicePointFilter(tServicePoint.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetSaleByServicePointFilterCode() {
    //  ServicePoint__c.ServicePointCode__c
        Test.startTest();
        ServicePoint__c tServicePoint = [SELECT Id, ServicePointCode__c FROM ServicePoint__c LIMIT 1];
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getSaleByServicePointFilterCode(tServicePoint.ServicePointCode__c);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetActiveRecordsBySaleId() {
    //  Sale__c
        Test.startTest();
        Sale__c tSale = [SELECT Id FROM Sale__c LIMIT 1];            
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getActiveRecordsBySaleId(tSale.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetRecordsByOpportunityId() {
    //  Opportunity
        Test.startTest();
        Opportunity tOpportunity = [SELECT Id FROM Opportunity LIMIT 1];            
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getRecordsByOpportunityId(tOpportunity.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'tOpportunity not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetRecordsByQuote() {
    //  SBQQ__Quote__c
        Test.startTest();
        SBQQ__Quote__c tQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];            
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getRecordsByQuote(tQuote.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetRecordsByContract() {
    //  Sale__c & Contract
        Test.startTest();
        Sale__c tSale = [SELECT Id FROM Sale__c LIMIT 1];
        Contract tContract = [SELECT Id FROM Contract LIMIT 1];            
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getRecordsByContract(tContract.Id, tSale.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetRecordsWithContractsByServicePointAndAccount() {
    //  ServicePoint__c & Account
        Test.startTest();
        ServicePoint__c tServicePoint = [SELECT Id FROM ServicePoint__c LIMIT 1];
        Account tAccount = [SELECT Id FROM Account LIMIT 1];            
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getRecordsWithContractsByServicePointAndAccount(tServicePoint.Id, tAccount.Id);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'Value of parameter is not matching');
        Test.stopTest();
    }
    @isTest
    static void testGetActiveRecordsByQuoteAndOpportunity() {
    //  List<String>
        Test.startTest();
        List<String> tLstQuote  = new List<String>();
        List<String> tLstOpportunity = new List<String>();           
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getActiveRecordsByQuoteAndOpportunity(tLstQuote, tLstOpportunity);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(),'Value of parameter is not matching');
        Test.stopTest();
    }
}