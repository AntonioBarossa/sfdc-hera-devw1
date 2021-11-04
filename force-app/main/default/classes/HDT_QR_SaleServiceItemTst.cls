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

        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, false, accList[0].id, 'Attiva');
        List<Campaign> campList = HDT_UTL_DataFactoryTst.createCampaign(1, true);
        saleList[0].Campaign__c = campList[0].Id;
        saleList[0].Agency__c = 'testAgency';
        insert saleList;
        
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPointList[0].SupplyCity__c = 'testCity';
        servPointList[0].MarketOrigin__c = 'Libero';
        servPointList[0].SupplyProvince__c = 'testProvince';
        servPointList[0].MeterType__c = 'Multiorario';
        servPointList[0].UseCategory__c = '001-Uso cottura cibi';
        insert servPointList;
        
        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, false);
        oppList[0].Sale__c = saleList[0].Id;
        insert oppList;

        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<SBQQ__Quote__c> quoteList = HDT_UTL_DataFactoryTst.createQuote(1, false, orderList[0].Id, oppList[0].Id, saleList[0].Id, 'Quote');
        quoteList[0].Login__c = 'loginTest';
        quoteList[0].LoginGroup__c = 'loginGroupTest';
        quoteList[0].Role__c = 'roleTest';
        quoteList[0].Profile__c = 'profileTest';
        quoteList[0].NewClient__c = 'Y';
        quoteList[0].ResidentDeliveryAddress__c = 'Y';
        quoteList[0].ConsumptionRangeEE__c = 2;
        quoteList[0].ConsumptionRangeGAS__c = 2;
        quoteList[0].PowerFlow__c = 2;
        quoteList[0].AmendmentAllowed__c = false;
        quoteList[0].ContractReference__c = contractList[0].Id;
        quoteList[0].SBQQ__Account__c = accList[0].Id;
        insert quoteList;

        HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, oppList[0].Id, quoteList[0].Id, servPointList[0].Id);

    }

    @isTest
    static void testQueryExsistingCityAndType() {
    //  Sale__c & ServicePoint__c & SBQQ__Quote__c & Map<String, String> & Map<String, Decimal>
        Test.startTest();
        Sale__c tSale = [SELECT Id, Agency__c, Campaign__c FROM Sale__c LIMIT 1];
        ServicePoint__c tServicePoint = [SELECT Id, RecordType.DeveloperName, SupplyCity__c, MarketOrigin__c, SupplyProvince__c, MeterType__c, UseCategory__c  FROM ServicePoint__c LIMIT 1];
        //SBQQ__Quote__c tQuote = [SELECT Id, Login__c, LoginGroup__c, Role__c, Profile__c, NewClient__c, ResidentDeliveryAddress__c, ConsumptionRangeEE__c, ConsumptionRangeGAS__c, PowerFlow__c, AmendmentAllowed__c FROM SBQQ__Quote__c WHERE AmendmentAllowed__c = false];
        Map<String,String> tMapString = new Map<String,String>();
        tMapString.put('login', 'loginTest');
        tMapString.put('loginGroup', 'loginGroupTest');
        tMapString.put('role', 'roleTest');
        tMapString.put('profile', 'profileTest');
        tMapString.put('newClient', 'Y');
        tMapString.put('residentDeliveryAddress', 'Y');
        Map<String,Decimal> tMapDecimal = new Map<String,Decimal>();
        tMapDecimal.put('consumptionRangeEle', 2);
        tMapDecimal.put('consumptionRangeGas', 2);
        tMapDecimal.put('powerFlow', 2);
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
        System.assertNotEquals(true, testSaleServItem.isEmpty(), 'getSaleByServicePoint did not work correctly');
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
        SBQQ__Quote__c tQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        tLstQuote.add(tquote.Id);

        List<String> tLstOpportunity = new List<String>();
        Opportunity tOpp = [SELECT Id FROM Opportunity LIMIT 1];
        tLstOpportunity.add(tOpp.Id);
                
        HDT_QR_SaleServiceItem qrSaleServItem = new HDT_QR_SaleServiceItem();
    
        List<SaleServiceItem__c> testSaleServItem = qrSaleServItem.getActiveRecordsByQuoteAndOpportunity(tLstQuote, tLstOpportunity);
        System.assertEquals(false, testSaleServItem.isEmpty(), 'testSaleServItem not populated correctly');
        System.assertNotEquals(true, testSaleServItem.isEmpty(),'Value of parameter is not matching');
        Test.stopTest();
    }
}