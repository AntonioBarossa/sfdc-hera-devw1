/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 17/08/2021
 * @description HDT_LC_ConfigureProduct Test Class
 * @history Fabricio Petkevicius Nunes – 17/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_ConfigureProductTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_LC_ConfigureProduct.wrapReturnValidity wrapValidity=new HDT_LC_ConfigureProduct.wrapReturnValidity();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};
		insert permissionSetAssignments;

		System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Azienda', 'Aziende SME');
            accounts[0].VATNumber__c='12345678901';
            insert accounts;
			List<BillingProfile__c> billProfs=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id);
			contracts[0].BillingProfile__c=billProfs[0].Id;
			insert contracts;

			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, false);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');

			opps[0].Sale__c=sales[0].Id;
			insert opps;

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
	}

	@isTest
	public static void testgetQuotes(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];


		List<Map<String, List<SObject>>> testgetQuotes=HDT_LC_ConfigureProduct.getQuotes(tSales[0].Id);

		System.assertEquals(false, testgetQuotes.isEmpty(), 'SBQQ__Quote__c not returned');
		System.assertNotEquals(true, testgetQuotes.isEmpty(),'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	public static void testcancelQuote(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<SBQQ__Quote__c> tQuotes=[SELECT Id, SBQQ__Type__c
			                              FROM SBQQ__Quote__c
			                              WHERE SBQQ__Type__c='Quote'];

			List<Opportunity> tOpps=[SELECT Id, Name
			                         FROM Opportunity
			                         WHERE Name='testOpportunity0'];


			HDT_LC_ConfigureProduct.cancelQuote(tQuotes[0].Id, tOpps[0].Id, 'Errata operativita');
			HDT_LC_ConfigureProduct.cancelQuote(tQuotes[0].Id, tOpps[0].Id, 'Volonta cliente');

			List<SBQQ__Quote__c> tCancelQuotes=[SELECT Id, SBQQ__Type__c, SBQQ__Status__c
			                                    FROM SBQQ__Quote__c
			                                    WHERE Id=:tQuotes[0].Id];

			System.assertEquals('Rejected', tCancelQuotes[0].SBQQ__Status__c, 'SBQQ__Quote__c not cancelled');
			System.assertNotEquals('', tCancelQuotes[0].SBQQ__Status__c,'value of parameter is not matching');

			Test.stopTest();
		}
	}

	@isTest
	public static void testcheckQuotesHaveQuoteLines(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];


		HDT_LC_ConfigureProduct.checkQuotesHaveQuoteLines(tSales[0]);
        
        
        List<SBQQ__QuoteLine__c> quotes = [Select id From SBQQ__QuoteLine__c];

		System.assertEquals(1, quotes.size(), 'value of parameter is matching');
		System.assertNotEquals(null, quotes[0], 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	public static void testcheckServicePointAssocs(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];


		HDT_LC_ConfigureProduct.checkServicePointAssocs(tSales[0]);

        List<ServicePoint__c> points = [Select id From ServicePoint__c];

		System.assertEquals(1, points.size(), 'value of parameter is matching');
		System.assertNotEquals(null, points[0], 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	public static void testcheckDuplicatedServicePointAssocs(){

		Test.startTest();

		List<SBQQ__QuoteLine__c> tQuoteLines=[SELECT Id, ServicePoint__c, ServicePoint__r.ServicePointCode__c
		                                      FROM SBQQ__QuoteLine__c];


		HDT_LC_ConfigureProduct.checkDuplicatedServicePointAssocs(tQuoteLines);
        

		System.assertEquals(1, tQuoteLines.size(), 'value of parameter is matching');
		System.assertNotEquals(null, tQuoteLines, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	public static void testperformChecks(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];

		HDT_LC_ConfigureProduct.performChecks(tSales[0]);

		System.assertEquals(1, tSales.size(), 'value of parameter is matching');
		System.assertNotEquals(null, tSales, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	public static void testupdateSaleNext(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];

		HDT_LC_ConfigureProduct.updateSaleNext(tSales[0]);

		List<SBQQ__Quote__c> tUpdatedQuote=[SELECT Id, SBQQ__SubscriptionTerm__c
		                                    FROM SBQQ__Quote__c
		                                    WHERE SBQQ__SubscriptionTerm__c=1200
		                                    LIMIT 1];


		System.assertEquals(false, tUpdatedQuote.isEmpty(), 'SBQQ__Quote__c not updated');
		System.assertNotEquals(true, tUpdatedQuote.isEmpty(), 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	public static void testamendContract(){
		Test.startTest();

		List<Contract> tContract=[SELECT Id, SAPContractCode__c
		                          FROM Contract
		                          WHERE SAPContractCode__c='3011913470'];

		tContract[0].SBQQ__AmendmentStartDate__c=Date.today();
		tContract[0].EndDate=Date.today().addDays(30);
		update tContract;

		SBQQ__Quote__c tAmendContract=HDT_LC_ConfigureProduct.amendContract(tContract[0].Id);

		System.assertEquals(true, tAmendContract!=null, 'SBQQ__Quote__c not returned');
		System.assertNotEquals(false, tAmendContract!=null, 'value of parameter is not matching');
		Test.stopTest();
	}

	@isTest
	public static void testupdateSalePrevious(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];

		HDT_LC_ConfigureProduct.updateSalePrevious(tSales[0]);


		System.assertEquals(1, tSales.size(), 'value of parameter is matching');
		System.assertNotEquals(null, tSales, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	public static void testcheckApprovedProduct(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name, Account__c, Account__r.Id
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];

		List<Product2> tprods=[SELECT Id, Name
		                       FROM Product2
		                       WHERE Name='POD'
		                       LIMIT 1];

		tprods[0].Status__c='Scaduta';
		update tprods;

		List<Account> tAccounts=[SELECT Id, VATNumber__c
		                         FROM Account
		                         WHERE VATNumber__c='12345678901'];

		List<SBQQ__QuoteLine__c> tQuoteLines=[SELECT Id, ServicePoint__c, ServicePoint__r.ServicePointCode__c
		                                      FROM SBQQ__QuoteLine__c];


		HDT_LC_ConfigureProduct.checkApprovedProduct(tSales[0]);

		List<wrts_prcgvr__Activity__c> activtyCusts=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, tAccounts[0].Id);
		activtyCusts[0].QuoteLine__c=tQuoteLines[0].Id;
		insert activtyCusts;

		wrapValidity=HDT_LC_ConfigureProduct.checkApprovedProduct(tSales[0]);

		System.assertEquals(false, wrapValidity==null, 'WrapValidity not returned');
		System.assertNotEquals(true, wrapValidity==null, 'value of parameter is not matching');

		Test.stopTest();
	}
}