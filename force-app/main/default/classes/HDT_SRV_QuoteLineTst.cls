/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 30/07/2021
 * @description Test Class for HDT_SRV_QuoteLine.cls
 * @history Fabricio Petkevicius Nunes – 30/07/2021 – Created class
 */
@isTest
public class HDT_SRV_QuoteLineTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void setup(){

		Id standardUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_STANDARD_USER_NAME);
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_STANDARD_USER_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

			List<Opportunity> opportunities=HDT_UTL_DataFactoryTst.createOpportunity(1, true);

			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');

			List<ServicePoint__c> servicePoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);

			List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, false);
			products[0].Family='VAS Opzione prodotto';
			products[0].Name='POD';
			insert products;

			Id pricebookId=Test.getStandardPricebookId();

			List<PricebookEntry> pricebookEntry=HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebookId);

			List<BillingProfile__c> billingProfiles=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);

			List<Order> orders=HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, accounts[0].Id, sales, pricebookId);
			orders[0].BillingProfile__c=billingProfiles[0].Id;

			insert orders;

			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opportunities[0].Id, sales[0].Id, 'Amendment');


			quotes[0].SBQQ__Account__c=accounts[0].Id;
			quotes[0].SBQQ__PricebookId__c=pricebookId;

			insert quotes;

			opportunities[0].SBQQ__PrimaryQuote__c=quotes[0].Id;
			opportunities[0].Account=accounts[0];

			update opportunities;

			orders[0].SBQQ__Quote__c=quotes[0].Id;

			update orders;

			Quote tQuote=new Quote();
			tQuote.Name='test';
			tQuote.OpportunityId=opportunities[0].Id;
			tquote.Pricebook2Id=pricebookId;

			insert tQuote;

			List<QuoteLineItem> quoteLineItems=new List<QuoteLineItem>();
			QuoteLineItem quoteLineItem=new QuoteLineItem();
			quoteLineItem.Description='test';
			quoteLineItem.QuoteId=tQuote.Id;
			quoteLineItem.PricebookEntryId=pricebookEntry[0].Id;
			quoteLineItem.Quantity=1;
			quoteLineItem.UnitPrice=10;
			quoteLineItem.Product2=products[0];

			insert quoteLineItem;
		}
	}

	@isTest
	static void testcheckAccessInit(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){
			tstQuoteLineSrv.checkAccessInit('SupplyCity__c, SBQQ__Quote__c', 'create');
		}


		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}

	@isTest
	static void testcheckReadAccess(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){
			tstQuoteLineSrv.checkReadAccess('SupplyCity__c, SBQQ__Quote__c');
		}

		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}

	@isTest
	static void testcheckCreateAccess(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){
			tstQuoteLineSrv.checkCreateAccess('SupplyCity__c, SBQQ__Quote__c');
		}

		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}

	@isTest
	static void testcheckUpdateAccess(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){

			tstQuoteLineSrv.checkUpdateAccess('SupplyCity__c, SBQQ__Quote__c');
		}

		// System.assertEquals('', '', '');

		// System.assertNotEquals('', '');

		Test.stopTest();
	}

	@isTest
	static void testcreateRecords(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];


		System.runAs(u){

			Test.startTest();

			SBQQ__Quote__c tQuote=[SELECT Id, SBQQ__Type__c
			                       FROM SBQQ__Quote__c
			                       Where SBQQ__Type__c='Amendment'
			                       LIMIT 1];

			Product2 tProduct=[SELECT Id, Name
			                   FROM Product2 
			                   WHERE Name='POD'
			                   LIMIT 1];

			ServicePoint__c tServPoint=[SELECT Id, ServicePointCode__c
			                            FROM ServicePoint__c
			                            WHERE ServicePointCode__c='testServicePointCode'
			                            LIMIT 1];

			BillingProfile__c tBillProfile=[SELECT Id
			                                FROM BillingProfile__c
			                                LIMIT 1];

			Account tAccount=[SELECT Id, CompanyOwner__c
			                  FROM Account
			                  WHERE CompanyOwner__c='HERA COMM'
			                  LIMIT 1];

			List<SBQQ__QuoteLine__c> quoteLines=new List<SBQQ__QuoteLine__c>();
			SBQQ__QuoteLine__c quoteLine=new SBQQ__QuoteLine__c();
			quoteLine.SBQQ__Quote__c=tQuote.Id;
			quoteLine.SBQQ__Product__c=tProduct.Id;
			quoteLine.ServicePoint__c=tServPoint.Id;
			quoteLine.SupplyCity__c='test city';
			quoteLine.BillingProfile__c=tBillProfile.Id;
			quoteLine.Agency__c=tAccount.Id;
			quoteLine.OwnerAC__c='Si';

			quoteLines.add(quoteLine);


			HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

			List<SBQQ__QuoteLine__c> quotLinTest=tstQuoteLineSrv.createRecords(quoteLines);

			System.debug('quotLinTest = '+quotLinTest);

			System.assertEquals('test city', quotLinTest[0].SupplyCity__c, 'Quote Line not created');

			System.assertNotEquals('', quotLinTest[0].SupplyCity__c);

			Test.stopTest();

		}
	}

	@isTest
	static void testupdateRecord(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];


		System.runAs(u){

			Test.startTest();

			SBQQ__Quote__c tQuote=[SELECT Id, SBQQ__Type__c
			                       FROM SBQQ__Quote__c
			                       Where SBQQ__Type__c='Amendment'
			                       LIMIT 1];

			Product2 tProduct=[SELECT Id, Name
			                   FROM Product2 
			                   WHERE Name='POD'
			                   LIMIT 1];

			ServicePoint__c tServPoint=[SELECT Id, ServicePointCode__c
			                            FROM ServicePoint__c
			                            WHERE ServicePointCode__c='testServicePointCode'
			                            LIMIT 1];

			BillingProfile__c tBillProfile=[SELECT Id
			                                FROM BillingProfile__c
			                                LIMIT 1];

			Account tAccount=[SELECT Id, CompanyOwner__c
			                  FROM Account
			                  WHERE CompanyOwner__c='HERA COMM'
			                  LIMIT 1];

			SBQQ__QuoteLine__c quoteLine=new SBQQ__QuoteLine__c();
			quoteLine.SBQQ__Quote__c=tQuote.Id;
			quoteLine.SBQQ__Product__c=tProduct.Id;
			quoteLine.ServicePoint__c=tServPoint.Id;
			quoteLine.SupplyCity__c='test city';
			quoteLine.BillingProfile__c=tBillProfile.Id;
			quoteLine.Agency__c=tAccount.Id;
			quoteLine.OwnerAC__c='Si';

			insert quoteline;

			quoteline.SBQQ__Description__c='test@test.com';

			HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

			tstQuoteLineSrv.updateRecord(quoteLine);

			SBQQ__QuoteLine__c tstUpdQuoteLine=[SELECT Id, SBQQ__Description__c
			                                    FROM SBQQ__QuoteLine__c
			                                    WHERE Id=:quoteline.id
			                                    LIMIT 1];

			System.debug('tstUpdQuoteLine = '+tstUpdQuoteLine);

			//System.assertEquals('test updated city', tstUpdQuoteLine.SupplyCity__c, 'Quote Line not updated');

			//System.assertNotEquals('', tstUpdQuoteLine.SupplyCity__c);

			Test.stopTest();

		}
	}

	@isTest
	static void testupdateRecords(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];


		System.runAs(u){

			Test.startTest();

			SBQQ__Quote__c tQuote=[SELECT Id, SBQQ__Type__c
			                       FROM SBQQ__Quote__c
			                       Where SBQQ__Type__c='Amendment'
			                       LIMIT 1];

			Product2 tProduct=[SELECT Id, Name
			                   FROM Product2 
			                   WHERE Name='POD'
			                   LIMIT 1];

			ServicePoint__c tServPoint=[SELECT Id, ServicePointCode__c
			                            FROM ServicePoint__c
			                            WHERE ServicePointCode__c='testServicePointCode'
			                            LIMIT 1];

			BillingProfile__c tBillProfile=[SELECT Id
			                                FROM BillingProfile__c
			                                LIMIT 1];

			Account tAccount=[SELECT Id, CompanyOwner__c
			                  FROM Account
			                  WHERE CompanyOwner__c='HERA COMM'
			                  LIMIT 1];

			List<SBQQ__QuoteLine__c> quoteLines=new List<SBQQ__QuoteLine__c>();
			SBQQ__QuoteLine__c quoteLine=new SBQQ__QuoteLine__c();
			quoteLine.SBQQ__Quote__c=tQuote.Id;
			quoteLine.SBQQ__Product__c=tProduct.Id;
			quoteLine.ServicePoint__c=tServPoint.Id;
			quoteLine.SupplyCity__c='test city';
			quoteLine.BillingProfile__c=tBillProfile.Id;
			quoteLine.Agency__c=tAccount.Id;
			quoteLine.OwnerAC__c='Si';

			quoteLines.add(quoteLine);


			insert quoteLines;

			quoteline.EmailRecipientVAS__c='test@test.com';

			quoteLines.add(quoteLine);


			HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

			tstQuoteLineSrv.updateRecords(quoteLines);

			SBQQ__QuoteLine__c tstUpdQuoteLine=[SELECT Id, EmailRecipientVAS__c
			                                    FROM SBQQ__QuoteLine__c
			                                    WHERE EmailRecipientVAS__c='test@test.com'
			                                    LIMIT 1];

			System.debug('tstUpdQuoteLine = '+tstUpdQuoteLine);

			//System.assertEquals('test updated city', tstUpdQuoteLine.SupplyCity__c, 'Quote Line not updated');

			//System.assertNotEquals('', tstUpdQuoteLine.SupplyCity__c);

			Test.stopTest();

		}
	}

	@isTest
	static void testgroupRecordsByQuote(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];


		System.runAs(u){

			Test.startTest();

			List<SBQQ__Quote__c> tQuote=[SELECT Id, SBQQ__Type__c
			                             FROM SBQQ__Quote__c
			                             Where SBQQ__Type__c='Amendment'
			                             LIMIT 1];

			Product2 tProduct=[SELECT Id, Name
			                   FROM Product2 
			                   WHERE Name='POD'
			                   LIMIT 1];

			ServicePoint__c tServPoint=[SELECT Id, ServicePointCode__c
			                            FROM ServicePoint__c
			                            WHERE ServicePointCode__c='testServicePointCode'
			                            LIMIT 1];

			BillingProfile__c tBillProfile=[SELECT Id
			                                FROM BillingProfile__c
			                                LIMIT 1];

			Account tAccount=[SELECT Id, CompanyOwner__c
			                  FROM Account
			                  WHERE CompanyOwner__c='HERA COMM'
			                  LIMIT 1];

			List<SBQQ__QuoteLine__c> quoteLines=new List<SBQQ__QuoteLine__c>();
			SBQQ__QuoteLine__c quoteLine=new SBQQ__QuoteLine__c();
			quoteLine.SBQQ__Quote__c=tQuote[0].Id;
			quoteLine.SBQQ__Product__c=tProduct.Id;
			quoteLine.ServicePoint__c=tServPoint.Id;
			quoteLine.SupplyCity__c='test city';
			quoteLine.BillingProfile__c=tBillProfile.Id;
			quoteLine.Agency__c=tAccount.Id;
			quoteLine.OwnerAC__c='Si';

			quoteLines.add(quoteLine);


			insert quoteLines;

			HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

			List<Map<String, List<SObject>>> methodReturn=tstQuoteLineSrv.groupRecordsByQuote(tQuote, quoteLines);

			System.debug('methodReturn = '+methodReturn);

			//System.assertEquals('test updated city', tstUpdQuoteLine.SupplyCity__c, 'Quote Line not updated');

			//System.assertNotEquals('', tstUpdQuoteLine.SupplyCity__c);

			Test.stopTest();

		}
	}
}