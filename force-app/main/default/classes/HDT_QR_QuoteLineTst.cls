/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 26/08/2021
 * @description HDT_QR_QuoteLine Test Classes
 * @history Lucas da Silva Fernandes – 26/08/2021 – Created Class
 */
@isTest
public with sharing class HDT_QR_QuoteLineTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_QR_QuoteLine qrLine = new HDT_QR_QuoteLine();

    @TestSetup
    static void setup(){
        
        // Id adminUserProfileId = HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		// User internalUser = HDT_UTL_DataFactoryTst.createInternalUser(AdminUserProfileId, false);
		// internalUser.UserPermissionsMarketingUser=true;
		// insert internalUser;

		// List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};
		// insert permissionSetAssignments;

		// System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();

			List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Opportunity> opportunities = HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');
			List<ServicePoint__c> servicePoints = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1, false);
			products[0].Family = 'VAS Prodotto';
			products[0].Name = 'POD';
            products[0].ProductCode = 'iddqd';
            products[0].Version__c = 'version';
			insert products;

			// Id pricebookId=Test.getStandardPricebookId();

			// List<PricebookEntry> pricebookEntry=HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebookId);

			List<BillingProfile__c> billingProfiles = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);

            List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id);
            contractList[0].BillingProfile__c = billingProfiles[0].Id;
            insert contractList;

			List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
			// orders[0].BillingProfile__c=billingProfiles[0].Id;
			// insert orders;

			List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opportunities[0].Id, sales[0].Id, 'Amendment');
			quotes[0].SBQQ__Account__c = accounts[0].Id;
            quotes[0].OrderReference__c = orders[0].Id;
            quotes[0].ContractReference__c = contractList[0].Id;
            quotes[0].SBQQ__Status__c = 'Accepted';
			// quotes[0].SBQQ__PricebookId__c=pricebookId;

			insert quotes;

			opportunities[0].SBQQ__PrimaryQuote__c = quotes[0].Id;
			opportunities[0].Account = accounts[0];
			update opportunities;

			orders[0].SBQQ__Quote__c = quotes[0].Id;
			update orders;

            List<SaleServiceItem__c> ssiList = HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opportunities[0].Id, quotes[0].Id, servicePoints[0].Id);

			List<SBQQ__QuoteLine__c> qlList = HDT_UTL_DataFactoryTst.createQuoteLines(products.get(0).Id, quotes.get(0).Id, 3, true);
            qlList[0].ServicePoint__c = servicePoints[0].Id;
            qlList[0].BillingProfile__c = billingProfiles[0].Id;
            qlList[0].SBQQ__Product__c = products[0].Id;
            qlList[0].SBQQ__RequiredBy__c = qlList[1].Id;
            qlList[0].Channel__c = 'SBT';
            qlList[0].PaymentMode__c = 'RID';
            qlList[0].SBQQ__Number__c = 1;
            qlList[0].ServicePointLinkItem__c = ssiList[0].Id;

            qlList[1].BillingProfile__c = billingProfiles[0].Id;
            qlList[1].SBQQ__Product__c = products[0].Id;
            qlList[1].SBQQ__RequiredBy__c = qlList[2].Id;
            qlList[1].Channel__c = 'CNN';     
            qlList[1].PaymentMode__c = 'RID';    
            qlList[1].SendingBillMode__c = 'Bolletta per e-mail';        

            qlList[2].Channel__c = 'NHK';

            update qlList;
        // }
    }

    @isTest
    public static void testGetRecordsBySale() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' ];
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, SBQQ__RequiredBy__r.PaymentMode__c FROM SBQQ__QuoteLine__c WHERE Channel__c = 'SBT'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsBySaleFilteredPaymentMethod(quote.Sale__c, quoteLine.SBQQ__RequiredBy__r.PaymentMode__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsBySaleFilteredPaymentMethod() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' ];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsBySale(quote.Sale__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsBySaleFilteredPaymentMethodPodPdr() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' ];

        SBQQ__QuoteLine__c qline = [SELECT Id, SBQQ__RequiredBy__r.PaymentMode__c, SBQQ__RequiredBy__r.SendingBillMode__c FROM SBQQ__QuoteLine__c WHERE Channel__c = 'SBT'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsBySaleFilteredPaymentMethodPodPdr(quote.Sale__c, qline.SBQQ__RequiredBy__r.PaymentMode__c, qline.SBQQ__RequiredBy__r.SendingBillMode__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsBySaleFilteredPaymentMethodforVas() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c, ContractReference__c, OrderReference__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];
        quote.OrderReference__c = null;
        quote.ContractReference__c = null;

        update quote;

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsBySaleFilteredPaymentMethodforVas(quote.Sale__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGgetQuoteLineAnalisiConsumi() {

        Test.startTest();

        Product2 prod = [SELECT Id, Name FROM Product2 WHERE Name = 'POD'];
        prod.Name = 'Analisi Consumi';
        update prod;

        SBQQ__QuoteLine__c ql = [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Channel__c = 'SBT'];

        List<String> stList = new List<String>();
        String st = String.valueOf(ql.SBQQ__RequiredBy__c);
        stList.add(st);

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getQuoteLineAnalisiConsumi(stList);

        System.assertEquals(ql.Id, quoteLineList[0].Id, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].Id, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetChildAnalisi() {

        Test.startTest();

        Product2 prod = [SELECT Id, Family FROM Product2 WHERE Name = 'POD'];
        prod.Family = 'VAS Fatturabili';
        update prod;

        SBQQ__QuoteLine__c ql = [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Channel__c = 'SBT'];

        List<String> stList = new List<String>();
        String st = String.valueOf(ql.SBQQ__RequiredBy__c);
        stList.add(st);

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getChildAnalisi(stList);

        System.assertEquals(ql.Id, quoteLineList[0].Id, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].Id, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsBySaleFilteredPaymentMethodNotNull() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsBySaleFilteredPaymentMethodNotNull(quote.Sale__c);

        System.assertEquals(quote.Id, quoteLineList[0].SBQQ__Quote__c, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__c, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsBySaleForBillingCheck() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsBySaleForBillingCheck(quote.Sale__c);

        System.assertEquals(quote.Id, quoteLineList[0].SBQQ__Quote__c, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__c, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsByQuoteFilteredPaymentMethodNotNull() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsByQuoteFilteredPaymentMethodNotNull(quote.Id);

        System.assertEquals(quote.Id, quoteLineList[0].SBQQ__Quote__c, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__c, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsForContractOrderRefVas() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsForContractOrderRefVas(quote.Id);

        System.assertEquals(quote.Id, quoteLineList[0].SBQQ__Quote__c, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__c, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsByContractFilteredPaymentMethodNotNull() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Sale__c, ContractReference__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsByContractFilteredPaymentMethodNotNull(quote.ContractReference__c, quote.Sale__c);

        System.assertEquals(quote.Id, quoteLineList[0].SBQQ__Quote__c, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__c, 'Quote line failed to query');


        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsBySaleFilteredByRequired() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];
        SBQQ__QuoteLine__c ql = [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Channel__c = 'SBT'];

        List<String> stList = new List<String>();
        String st = String.valueOf(ql.SBQQ__RequiredBy__c);
        stList.add(st);

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsBySaleFilteredByRequired(quote.Sale__c, stList);

        System.assertEquals(quote.Id, quoteLineList[0].SBQQ__Quote__c, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__c, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsByQuoteIdAndProductPod() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsByQuoteIdAndProductPod(quote.Id);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetPrimaryRecord() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        SBQQ__QuoteLine__c ql = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Channel__c = 'NHK'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getPrimaryRecord(quote.Id);

        System.assertEquals(ql.Id, quoteLineList[0].Id, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].Id, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsByQuoteId() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsByQuoteId(quote.Id);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetRecordsByContractAndProductPod() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c, ContractReference__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getRecordsByContractAndProductPod(quote.ContractReference__c, quote.Sale__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetActiveRecordsBySaleIdAndProductPod() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getActiveRecordsBySaleIdAndProductPod(quote.Sale__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetActiveRecords() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getActiveRecords(quote.Sale__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetLinkedQuoteLines() {

        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getLinkedQuoteLines(quote.Id);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }

    @isTest
    public static void testGetQuoteLinesWithCambioOfferta() {

        Test.startTest();

        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'POD'];
        product.Name = 'Analisi Consumi';
        update product;

        SBQQ__Quote__c quote = [SELECT Id, Name, Sale__c, AmendmentAllowed__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted'];

        List<SBQQ__QuoteLine__c> quoteLineList = qrLine.getQuoteLinesWithCambioOfferta(quote.Sale__c);

        System.assertEquals(quote.Name, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line succesfully queried');
        System.assertNotEquals(null, quoteLineList[0].SBQQ__Quote__r.Name, 'Quote line failed to query');

        Test.stopTest();
    }
}
