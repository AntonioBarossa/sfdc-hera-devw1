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

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(standardUserProfileId, false);

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

			HDT_UTL_DataFactoryTst.createServicePoint(1, true);

			List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, false);
			products[0].Family='VAS Opzione prodotto';
			products[0].Name='POD';
			insert products;

			Id pricebookId=Test.getStandardPricebookId();

			HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebookId);

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

			HDT_UTL_DataFactoryTst.createQuoteLines(products.get(0).Id, quotes.get(0).Id, 2, true);
			
		}
	}

	@isTest
	static void testcheckAccessInit(){

		Boolean finished = false;

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){
			tstQuoteLineSrv.checkAccessInit('SupplyCity__c, SBQQ__Quote__c', 'create');
		}

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Teste Ended');
	}

	@isTest
	static void testcheckReadAccess(){

		Boolean finished = false;

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){
			tstQuoteLineSrv.checkReadAccess('SupplyCity__c, SBQQ__Quote__c');
		}

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Teste Ended');
	}

	@isTest
	static void testcheckCreateAccess(){

		Boolean finished = false;

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){
			tstQuoteLineSrv.checkCreateAccess('SupplyCity__c, SBQQ__Quote__c');
		}

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Teste Ended');
	}

	@isTest
	static void testcheckUpdateAccess(){

		Boolean finished = false;

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		Test.startTest();

		HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

		System.runAs(u){

			tstQuoteLineSrv.checkUpdateAccess('SupplyCity__c, SBQQ__Quote__c');
		}

		finished = true;

		Test.stopTest();

		System.assertEquals(true, finished, 'Teste Ended');
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

				System.assertNotEquals('', quotLinTest[0].SupplyCity__c, '');

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

				SBQQ__QuoteLine__c existingQuoteLine = [SELECT Id, SBQQ__Description__c FROM SBQQ__QuoteLine__c WHERE CreatedbyId = :u.Id LIMIT 1];

				SBQQ__QuoteLine__c quoteLineToUpdate = new SBQQ__QuoteLine__c(Id = existingQuoteLine.Id, SBQQ__Description__c = 'test description');

				HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();
				

				tstQuoteLineSrv.updateRecord(quoteLineToUpdate);	

				

				SBQQ__QuoteLine__c tstUpdQuoteLine=[SELECT Id, SBQQ__Description__c
													FROM SBQQ__QuoteLine__c
													WHERE Id =: existingQuoteLine.Id];

				System.assertEquals(quoteLineToUpdate.SBQQ__Description__c, tstUpdQuoteLine.SBQQ__Description__c, 'Quote Line was not updated');

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

				List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT Id, SBQQ__Description__c FROM SBQQ__QuoteLine__c WHERE CreatedbyId = :u.Id LIMIT 2];

				List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

				HDT_SRV_QuoteLine tstQuoteLineSrv=new HDT_SRV_QuoteLine();

				for (SBQQ__QuoteLine__c ql : existingQuoteLines) {
					
					quoteLinesToUpdate.add(new SBQQ__QuoteLine__c(Id = ql.Id, SBQQ__Description__c = 'test description' + ql.Id));
				}

				tstQuoteLineSrv.updateRecords(quoteLinesToUpdate);

				List<SBQQ__QuoteLine__c> tstUpdQuoteLines=[SELECT Id, SBQQ__Description__c FROM SBQQ__QuoteLine__c WHERE Id IN :existingQuoteLines];

				System.assertEquals('test description' + tstUpdQuoteLines.get(0).Id, tstUpdQuoteLines.get(0).SBQQ__Description__c, 'Quote Lines [1] were not updated');
				System.assertEquals('test description' + tstUpdQuoteLines.get(1).Id, tstUpdQuoteLines.get(1).SBQQ__Description__c, 'Quote Lines [2] were not updated');

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

				List<SBQQ__QuoteLine__c> existingQuoteLines = [SELECT Id, SBQQ__Description__c, SBQQ__Quote__c, SBQQ__Quote__r.Id FROM SBQQ__QuoteLine__c WHERE CreatedbyId = :u.Id LIMIT 2];
				SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = existingQuoteLines.get(0).SBQQ__Quote__c);

				HDT_SRV_QuoteLine tstQuoteLineSrv = new HDT_SRV_QuoteLine();

				List<Map<String, List<SObject>>> quoteLineMap = tstQuoteLineSrv.groupRecordsByQuote(new List<SBQQ__Quote__c>{quote}, existingQuoteLines);

				System.debug('methodReturn = ' + quoteLineMap.get(0));

				System.assertEquals(2, quoteLineMap.get(0).get('quoteLines').size(), 'The quote lines weren\'t grouped correctly');

			Test.stopTest();

		}
	}
}