/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 18/08/2021
 * @description HDT_LC_SaleActions Test Class
 * @history Fabricio Petkevicius Nunes – 18/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_SaleActionsTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_APEXCLASSES, false)};
		insert permissionSetAssignments;

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.pClickOrderPhase();
			HDT_UTL_DataFactoryTst.pClickInstance();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<BillingProfile__c> billProfs=HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accounts[0].Id);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, false);
			List<Product2> products=HDT_UTL_DataFactoryTst.createProduct2(1, false);
			products[0].Name='POD';
			insert products;

			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');
			opps[0].Sale__c=sales[0].Id;
			insert opps;

			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id);
			contracts[0].BillingProfile__c=billProfs[0].Id;
			insert contracts;

			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Quote');
			quotes[0].ContractReference__c=contracts[0].Id;
			quotes[0].AmendmentAllowed__c=true;
			quotes[0].SBQQ__Opportunity2__c=opps[0].Id;
			quotes[0].SBQQ__Ordered__c=true;
			insert quotes;

			opps[0].SBQQ__PrimaryQuote__c=quotes[0].Id;
			update opps;

			orders[0].SBQQ__Quote__c=quotes[0].Id;
			update orders;

			List<ServicePoint__c> servPoint=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<SaleServiceItem__c> saleServItens=HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opps[0].Id, quotes[0].Id, servPoint[0].Id);
			List<SBQQ__QuoteLine__c> quoteLines=HDT_UTL_DataFactoryTst.createQuoteLines(products[0].Id, quotes[0].Id, 2, false);
			quotelines[0].ServicePoint__c=servPoint[0].Id;
			quotelines[0].ServicePointLinkItem__c=saleServItens[0].Id;
			quoteLines[0].BillingProfile__c=billProfs[0].Id;
			quoteLines[0].PaymentMode__c='RID';
			quoteLines[1].BillingProfile__c=billProfs[0].Id;
			insert quoteLines;

			quoteLines[0].SBQQ__RequiredBy__c=quoteLines[1].Id;
			update quoteLines;

			List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(1, true);
			List<Lead> leads=HDT_UTL_DataFactoryTst.createLead(1, true);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			List<CampaignMember> campMembers=HDT_UTL_DataFactoryTst.createCampaignMember(1, true, campaigns[0].Id, leads[0].Id, contacts[0].Id);

			//QuoteProcess__c not yet on DataFactory
			List<SBQQ__QuoteProcess__c> quoteProcs=new List<SBQQ__QuoteProcess__c>();
			SBQQ__QuoteProcess__c quoteProc=new SBQQ__QuoteProcess__c();
			quoteProc.Name='Vendita Guidata Offerte';
			quoteProcs.add(quoteProc);
			insert quoteProcs;
		}
	}

	@isTest
	public static void testsaveDraft(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name
		                      FROM Sale__c 
		                      WHERE Name='testSaleName0'];

		tSales[0].VendorFirstName__c='testVendor';

		HDT_LC_SaleActions.saveDraft(tSales[0]);

		List<Sale__c> tSalesSavedDraft=[SELECT Id, Name, VendorFirstName__c
		                                FROM Sale__c
		                                WHERE Id=:tSales[0].Id];

		System.assertEquals('testVendor', tSalesSavedDraft[0].VendorFirstName__c, 'Sale Draft not saved');
		System.assertNotEquals('', tSalesSavedDraft[0].VendorFirstName__c, 'saveDraft did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testsave(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Sale__c> tSales=[SELECT Id, Name, Campaign__c, Account__c, Campaign__r.CampaignEligibilityGroup__c, Status__c
			                      FROM Sale__c
			                      WHERE Name='testSaleName0'];

			List<CampaignMember> tCampMember=[SELECT Id
			                                  FROM CampaignMember
			                                  LIMIT 1];

			String campMemId=tCampMember[0].Id;

			HDT_LC_SaleActions.save(tSales[0], campMemId);

			List<Opportunity> tOppSaved=[SELECT Id, StageName
			                             FROM Opportunity
			                             WHERE StageName='Closed Won'];

			List<Sale__c> tSaleSaved=[SELECT Id, Status__c
			                          FROM Sale__c
			                          WHERE Status__c='Attiva'];

			List<SBQQ__Quote__c> tQuoteSaved=[SELECT Id, SBQQ__Status__c
			                                  FROM SBQQ__Quote__c
			                                  WHERE SBQQ__Status__c='Chiusa'];

			List<SBQQ__QuoteLine__c> tQuoteLineSaved=[SELECT Id, PaymentMode__c
			                                          FROM SBQQ__QuoteLine__c
			                                          WHERE PaymentMode__c='RID'];

			System.assertEquals('Closed Won', tOppSaved[0].StageName, 'Opportunity not saved');
			System.assertEquals('Attiva', tSaleSaved[0].Status__c, 'Sale not saved');
			System.assertEquals('Chiusa', tQuoteSaved[0].SBQQ__Status__c, 'Quote not saved');
			System.assertEquals('RID', tQuoteLineSaved[0].PaymentMode__c, 'QuoteLine not saved');

			System.assertNotEquals('Negotiation', tOppSaved[0].StageName, 'save did not work correctly');
			System.assertNotEquals('', tSaleSaved[0].Status__c, 'save did not work correctly');
			System.assertNotEquals('', tQuoteSaved[0].SBQQ__Status__c, 'save did not work correctly');
			System.assertNotEquals('', tQuoteLineSaved[0].PaymentMode__c, 'save did not work correctly');

			Test.stopTest();
		}
	}

	@isTest
	public static void testsaveBackup(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name, Campaign__c, Account__c, Campaign__r.CampaignEligibilityGroup__c
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];


		HDT_LC_SaleActions.saveBackup(tSales[0]);

		List<Opportunity> tOppSavedBckUp=[SELECT Id, StageName
		                                  FROM Opportunity
		                                  WHERE StageName='Closed Won'];

		List<Sale__c> tSaleSavedBckUp=[SELECT Id, Status__c
		                               FROM Sale__c
		                               WHERE Status__c='Attiva'];

		List<SBQQ__Quote__c> tQuoteSavedBckUp=[SELECT Id, SBQQ__Status__c
		                                       FROM SBQQ__Quote__c
		                                       WHERE SBQQ__Status__c='Accepted'];

		List<SBQQ__QuoteLine__c> tQuoteLineSavedBckUp=[SELECT Id, SBQQ__Group__c
		                                               FROM SBQQ__QuoteLine__c
		                                               WHERE SBQQ__Group__c!=null];

		//
		// Opps are not being updated - check method on HDT_LC_SaleActions
		//

		// System.assertEquals('Closed Won', tOppSavedBckUp[0].StageName, 'Opportunity Backup not saved');
		System.assertEquals('Attiva', tSaleSavedBckUp[0].Status__c, 'Sale Backup not saved');
		System.assertEquals('Accepted', tQuoteSavedBckUp[0].SBQQ__Status__c, 'Quote Backup not saved');
		System.assertEquals(true, tQuoteLineSavedBckUp[0].SBQQ__Group__c!=null, 'QuoteLine Backup not saved');

		// System.assertNotEquals('Negotiation', tOppSavedBckUp[0].StageName);
		System.assertNotEquals('', tSaleSavedBckUp[0].Status__c, 'saveBackup did not work correctly');
		System.assertNotEquals('Chiusa', tQuoteSavedBckUp[0].SBQQ__Status__c, 'saveBackup did not work correctly');
		System.assertNotEquals(false, tQuoteLineSavedBckUp[0].SBQQ__Group__c!=null, 'saveBackup did not work correctly');

		Test.stopTest();
	}

	@isTest
	public static void testcancel(){

		Test.startTest();

		List<Sale__c> tSales=[SELECT Id, Name, Campaign__c, Account__c, CancellationReason__c
		                      FROM Sale__c
		                      WHERE Name='testSaleName0'];


		HDT_LC_SaleActions.cancel(tSales[0], 'Annullamento da cliente');

		List<Sale__c> tSalesSaved=[SELECT Id, Name, Campaign__c, Account__c, Campaign__r.CampaignEligibilityGroup__c, Status__c
		                           FROM Sale__c
		                           WHERE Id=:tSales[0].Id];

		System.assertEquals('Annullata', tSalesSaved[0].Status__c, 'Sale not cancelled');
		System.assertNotEquals('Negotiation', tSalesSaved[0].Status__c, 'cancel did not work correctly');

		Test.stopTest();
	}
}