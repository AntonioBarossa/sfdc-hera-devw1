/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 16/08/2021
 * @description HDT_LC_EditQuote Test Class
 * @history Fabricio Petkevicius Nunes – 16/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_EditQuoteTst{
	@testSetup
	static void setup(){

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<BillingProfile__c> billProfs=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);
		List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id);
		contracts[0].BillingProfile__c=billProfs[0].Id;
		insert contracts;
		List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
		List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');
		List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Quote');
		quotes[0].ContractReference__c=contracts[0].Id;
		quotes[0].AmendmentAllowed__c=true;
		insert quotes;

		opps[0].SBQQ__PrimaryQuote__c=quotes[0].Id;
		update opps;

		List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, false);
		products[0].Name='POD';
		insert products;

		List<ServicePoint__c> servPoint=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
		List<SaleServiceItem__c> saleServItens=HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opps[0].Id, quotes[0].Id, servPoint[0].Id);
		List<SBQQ__QuoteLine__c> quoteLines=HDT_UTL_DataFactoryTst.createQuoteLines(products[0].Id, quotes[0].Id, 1, false);
		quotelines[0].ServicePoint__c=servPoint[0].Id;
		quotelines[0].ServicePointLinkItem__c=saleServItens[0].Id;
		insert quoteLines;
	}

	@isTest
	public static void testassocBillingProfileContract(){

		Test.startTest();

		List<SBQQ__Quote__c> tquotes=[SELECT Id, SBQQ__Type__c
		                              FROM SBQQ__Quote__c
		                              WHERE SBQQ__Type__c='Quote'];

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c 
		                      WHERE Name='testSaleName0'];


		boolean testReturn=HDT_LC_EditQuote.execModalExitActions(tSales[0].Id, tquotes[0].id);

		System.debug('testReturn = '+testReturn);

		List<ServicePoint__c> tServPoints=[SELECT Id, ServicePointCode__c
		                                   FROM ServicePoint__c
		                                   WHERE ServicePointCode__c='testServicePointCode'];

		delete tServPoints;

		boolean testReturn2=HDT_LC_EditQuote.execModalExitActions(tSales[0].Id, tquotes[0].id);

		System.debug('testReturn2 = '+testReturn2);

		System.assertEquals(true, testReturn, 'method return is wrong');
		System.assertEquals(true, testReturn2, 'method return is wrong');
		System.assertNotEquals(false, testReturn, 'method return is wrong');
		System.assertNotEquals(false, testReturn2, 'method return is wrong');

		Test.stopTest();
	}
}