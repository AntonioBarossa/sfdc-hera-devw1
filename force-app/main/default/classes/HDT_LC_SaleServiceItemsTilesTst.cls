/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 04/08/2021
 * @description Test Class for HDT_LC_SaleServiceItemsTiles.cls
 * @history Fabricio Petkevicius Nunes – 04/08/2021 – Created class
 */
@isTest
public class HDT_LC_SaleServiceItemsTilesTst{
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

			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);

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
			quotes[0].OrderReference__c=orders[0].Id;
			quotes[0].ContractReference__c=contracts[0].Id;
			quotes[0].SupplyCity__c='Roma';
			//quotes[0].IsVAS__c=true;

			insert quotes;

			opportunities[0].SBQQ__PrimaryQuote__c=quotes[0].Id;
			opportunities[0].Account=accounts[0];
			opportunities[0].Sale__c=sales[0].Id;

			update opportunities;

			orders[0].SBQQ__Quote__c=quotes[0].Id;

			update orders;

            List<SaleServiceItem__c> saleServiceItens = HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opportunities[0].Id, quotes[0].Id, servicePoints[0].Id);
		}
	}

	@isTest
	static void testgetTiles(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];


		System.runAs(u){
			Test.startTest();

			Sale__c tSale=[SELECT Id, Status__c
			               FROM Sale__c
			               WHERE Status__c='Bozza'
			               LIMIT 1];

			Map<String, List<List<SObject>>> tgetTiles=HDT_LC_SaleServiceItemsTiles.getTiles(tsale.Id);

			System.debug('tgetTiles = '+tgetTiles);

			System.assertEquals(2, tgetTiles.size(), 'Return is wrong');

			System.assertNotEquals(1, tgetTiles.size(), 'getTiles did not work correctly');

			Test.stopTest();

		}
	}

	@isTest
	static void testdeleteTile(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){
			Test.startTest();

			Opportunity tOpp=[SELECT Id, StageName
			                  FROM Opportunity
			                  WHERE StageName='Negotiation'
			                  LIMIT 1];

			HDT_LC_SaleServiceItemsTiles.deleteTile(tOpp.Id, 'Errata operativita');

			HDT_LC_SaleServiceItemsTiles.deleteTile(tOpp.Id, 'Volonta cliente');

			Opportunity tOppUpdt=[SELECT Id, StageName
			                      FROM Opportunity
			                      WHERE StageName='Closed Lost'
			                      LIMIT 1];


			System.debug('tOppUpdt = '+tOppUpdt);

			System.assertEquals('Closed Lost', tOppUpdt.StageName, 'Opportunity not updated');

			System.assertNotEquals('Negotiation', tOppUpdt.StageName, 'deleteTile did not work correctly');

			Test.stopTest();

		}
	}
}