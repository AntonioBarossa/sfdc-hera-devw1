/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 25/08/2021
 * @description HDT_QR_Quote Test Classes
 * @history Lucas da Silva Fernandes – 25/08/2021 – Created Class
 */

 @isTest
public with sharing class HDT_QR_QuoteTst {

    private static HDT_QR_Quote sbqqQuote = new HDT_QR_Quote();
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser) {

            List<Account> acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
            List<Opportunity> opp = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
            List<Campaign> cmpList = HDT_UTL_DataFactoryTst.createCampaign(1, true);
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, acc[0].Id, 'Bozza');
            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, acc[0].Id);
            
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, false, acc[0].Id, sales[0].Id);
            orders[0].Phase__c = 'Bozza';
            insert orders;

            List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opp[0].Id, sales[0].Id, 'Amendment');
            quotes[0].SBQQ__Status__c = 'Accepted';
            quotes[0].SBQQ__Ordered__c = true;
            quotes[0].SBQQ__LineItemsGrouped__c = true;
            quotes[0].SBQQ__OrderByQuoteLineGroup__c = true;
            quotes[0].AmendmentAllowed__c = true;
            quotes[0].ContractReference__c = contractList[0].Id;
            quotes[0].IsVAS__c = true;
            quotes[0].SalesCompany__c = 'Hera Comm Marche';
            quotes[0].SalesCompanyCode__c = 'HCM';
            quotes[0].SBQQ__Account__c = acc[0].Id;
            quotes[0].Campaign__c = cmpList[0].Id;
            quotes[0].Channel__c = 'SBT';
            quotes[0].Agency__c = 'CIA';
            quotes[0].FriendCode__c = 'Buzzlightyear';
            quotes[0].SaleBy__c = internalUser.Id;
            quotes[0].Market__c = 'Libero';
            quotes[0].SupplyCity__c = 'Roma';
            quotes[0].OrderReference__c = orders[0].Id;

            insert quotes;
            
            orders[0].SBQQ__Quote__c = quotes[0].Id;
            update orders;
        }
    }

    @isTest
    public static void testGetRecordsBySaleFilterStatus() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Name, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getRecordsBySaleFilterStatus(qt.Sale__c, 'Cancelled');

        System.assertEquals(qt.Name, quoteList[0].Name, 'Quote name matches');
        System.assertNotEquals(null, quoteList[0].Name, 'Quote name does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetActiveRecords() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Name, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getActiveRecords(qt.Sale__c);

        System.assertEquals(qt.Name, quoteList[0].Name, 'Quote name matches');
        System.assertNotEquals(null, quoteList[0].Name, 'Quote name does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordById() {

        Test.startTest();

        User tUser=[SELECT Id FROM User WHERE Alias='crmuser' LIMIT 1];

		System.runAs(tUser){

            SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

            SBQQ__Quote__c quote = sbqqQuote.getRecordById(qt.Id);

            System.assertEquals(qt.Id, quote.Id, 'Quote Id matches');
            System.assertNotEquals(null, quote.Id, 'Quote Id does not match');

        }

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordByIdFilterStatus() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Name FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        SBQQ__Quote__c quote = sbqqQuote.getRecordByIdFilterStatus(qt.Id, 'Cancelled');

        System.assertEquals(qt.Id, quote.Id, 'Quote Id matches');
        System.assertNotEquals(null, quote.Id, 'Quote Id does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsForSaleSaveEvent() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getRecordsForSaleSaveEvent(qt.Sale__c);

        System.assertEquals(qt.Id, quoteList[0].Id, 'Quote Id matches');
        System.assertNotEquals(null, quoteList[0].Id, 'Quote Id does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsForSaleCancelEvent() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Sale__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getRecordsForSaleCancelEvent(qt.Sale__c);

        System.assertEquals(qt.SBQQ__Status__c, quoteList[0].SBQQ__Status__c, 'Quote status matches');
        System.assertNotEquals(null, quoteList[0].SBQQ__Status__c, 'Quote status does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordByTypeAndAmendementAllowed() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Sale__c, SBQQ__Status__c, AmendmentAllowed__c, SBQQ__Type__c, SBQQ__Account__c 
                            FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<String> stList = new List<String>();
        String st = String.valueOf(qt.SBQQ__Account__c);
        stList.add(st);

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getRecordByTypeAndAmendementAllowed(qt.SBQQ__Status__c, qt.AmendmentAllowed__c, qt.SBQQ__Type__c, stList);

        System.assertEquals(qt.Sale__c, quoteList[0].Sale__c, 'Quote Sale matches');
        System.assertNotEquals(null, quoteList[0].Sale__c, 'Quote Sale does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordByTypeAndAmendementAllowedAndSaleId() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Sale__c, ContractReference__c, AmendmentAllowed__c, SBQQ__Type__c, SBQQ__Account__c 
                            FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<String> salesList = new List<String>();
        String st = String.valueOf(qt.Sale__c);
        salesList.add(st);

        List<String> contractList = new List<String>();
        st = String.valueOf(qt.ContractReference__c);
        contractList.add(st);

        List<String> exQtList = new List<String>();
        st = '';
        exQtList.add(st);

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getRecordByTypeAndAmendementAllowedAndSaleId(qt.AmendmentAllowed__c, qt.SBQQ__Type__c, salesList, contractList, exQtList);

        System.assertEquals(qt.Sale__c, quoteList[0].Sale__c, 'Quote Sale matches');
        System.assertNotEquals(null, quoteList[0].Sale__c, 'Quote Sale does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetQuotesBySaleAndContractReference() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Sale__c, ContractReference__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getQuotesBySaleAndContractReference(qt.Sale__c, qt.ContractReference__c);

        System.assertEquals(qt.Id, quoteList[0].Id, 'Quote Id matches');
        System.assertNotEquals(null, quoteList[0].Id, 'Quote Id does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetQuotesBySaleAndOrderReference() {

        Test.startTest();

        SBQQ__Quote__c qt = [SELECT Id, Sale__c, OrderReference__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];

        List<SBQQ__Quote__c> quoteList = sbqqQuote.getQuotesBySaleAndOrderReference(qt.Sale__c, qt.OrderReference__c);

        System.assertEquals(qt.Id, quoteList[0].Id, 'Quote Id matches');
        System.assertNotEquals(null, quoteList[0].Id, 'Quote Id does not match');

        Test.stopTest();
    }

    @isTest
    public static void testGetQuoteType() {

        Test.startTest();

        Order ord = [SELECT Id, SBQQ__Quote__r.SBQQ__Type__c FROM Order WHERE Name='testOrderName0' LIMIT 1];

        String quoteType = sbqqQuote.getQuoteType(ord.Id);

        System.assertEquals('Amendment', quoteType, 'Quote Id matches');

        Test.stopTest();
    }
}
