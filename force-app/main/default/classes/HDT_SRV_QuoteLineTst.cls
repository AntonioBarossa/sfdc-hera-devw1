/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 30/07/2021
 * @description Test Class for HDT_SRV_QuoteLine.cls
 * @history Fabricio Petkevicius Nunes – 30/07/2021 – Created class
 */
@isTest
public class HDT_SRV_QuoteLineTst{
	@TestSetup
	static void setup(){

		HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

        List<Opportunity> opportunities = HDT_UTL_DataFactoryTst.createOpportunity(1, true);

        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');

        List<ServicePoint__c> servicePoints = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        
        List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1, false);
        products[0].Family = 'VAS Opzione prodotto';
        products[0].Name = 'POD';
        insert products;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pricebookEntry = HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebookId);

        List<BillingProfile__c> billingProfiles = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);

        List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,false, accounts[0].Id, sales, pricebookId);
        orders[0].BillingProfile__c = billingProfiles[0].Id;

        insert orders;

        List<SBQQ__Quote__c> quotes = HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opportunities[0].Id, sales[0].Id, 'Amendment');


        quotes[0].SBQQ__Account__c = accounts[0].Id;
        quotes[0].SBQQ__PricebookId__c =  pricebookId;

        insert quotes;


        opportunities[0].SBQQ__PrimaryQuote__c = quotes[0].Id;
        opportunities[0].Account = accounts[0];

        update opportunities;


        orders[0].SBQQ__Quote__c = quotes[0].Id;

        update orders;

        List<SBQQ__DiscountSchedule__c> discScheds = new List<SBQQ__DiscountSchedule__c>();
        SBQQ__DiscountSchedule__c discSchedule = new SBQQ__DiscountSchedule__c();

        insert discSchedule;

        Quote tQuote = new Quote();
        tQuote.Name = 'test';
        tQuote.OpportunityId = opportunities[0].Id;
        tquote.Pricebook2Id = pricebookId;

        insert tQuote;  

        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        QuoteLineItem quoteLineItem = new QuoteLineItem();
        quoteLineItem.Description = 'test';
        quoteLineItem.QuoteId = tQuote.Id;
        quoteLineItem.PricebookEntryId = pricebookEntry[0].Id;
        quoteLineItem.Quantity = 1;
        quoteLineItem.UnitPrice = 10;
        quoteLineItem.Product2 =products[0];

        insert quoteLineItem;

        List<SBQQ__Cost__c> costs = new List<SBQQ__Cost__c>();
        SBQQ__Cost__c  tCost = new SBQQ__Cost__c();
        tCost.SBQQ__Product__c = products[0].Id;
        tCost.SBQQ__UnitCost__c = 10;

        insert tCost;

        

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quotes[0].Id;
        quoteLine.SBQQ__DiscountSchedule__c = discSchedule.Id;
        quoteLine.SBQQ__Cost__c = tCost.Id;
        quoteLine.ServicePoint__c = servicePoints[0].Id;
        quoteLine.SupplyCity__c = 'test city';
        quoteLine.BillingProfile__c = billingProfiles[0].Id;
        quoteLine.Agency__c = accounts[0].Id;
        quoteLine.OwnerAC__c = 'Si';

        insert quoteLine;

        
	}

	@isTest
	static void testcheckAccessInit(){

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		tstQuoteLineSrv.checkAccessInit('SupplyCity__c, SBQQ__Quote__c', 'create');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}


    @isTest
	static void testcheckReadAccess(){

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		tstQuoteLineSrv.checkReadAccess('SupplyCity__c, SBQQ__Quote__c');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}

    @isTest
	static void testcheckCreateAccess(){

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		tstQuoteLineSrv.checkCreateAccess('SupplyCity__c, SBQQ__Quote__c');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}


    @isTest
	static void testcheckUpdateAccess(){

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		tstQuoteLineSrv.checkUpdateAccess('SupplyCity__c, SBQQ__Quote__c');


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}
}