/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 10/08/2021
 * @description HDT_LC_SaleServiceContainer for Test Classes
 * @history Fabricio Petkevicius Nunes – 10/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_SaleServiceContainerTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		Id rtServPoint=constants.SERVICEPOINT_RECORDTYPEID_PELETRICCO;

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].id, 'Attiva');
		List<ServicePoint__c> servpoints=HDT_UTL_DataFactoryTst.createServicePoint(2, false);
		servpoints[0].SupplyProvince__c='AQ';
		servpoints[0].CommoditySector__c='Energia Elettrica';
		servpoints[0].SupplyType__c='Domestico';

		servpoints[1].SupplyProvince__c='AQ';
		servpoints[1].ServicePointCode__c='testServicePointCode2';
		servpoints[1].RecordTypeId=rtServPoint;
		servpoints[1].CommoditySector__c='Energia Elettrica';
		servpoints[1].SupplyType__c='Non Domestico';
		insert servpoints;

		List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].id);
		contracts[0].ServicePoint__c=servpoints[1].id;
		contracts[0].Status='Attivo';

		insert contracts;

		List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');
		List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
		List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(1, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
		quotes[0].ContractReference__c=contracts[0].Id;
		quotes[0].SBQQ__Account__c=accounts[0].Id;
		quotes[0].SBQQ__Status__c='In Review';
		quotes[0].Sale__c=sales[0].Id;

		insert quotes;

		contracts[0].SBQQ__Quote__c=quotes[0].Id;
		update contracts;

		List<SaleServiceItem__c> saleServItens;
		saleServItens=HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opps[0].Id, quotes[0].Id, servpoints[1].id);
	}

	@isTest
	public static void testcreateSaleServiceItemTile(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			Test.startTest();

			Sale__c tSale=[SELECT Id, Name, Account__c, Account__r.Category__c, Account__r.CompanyOwner__c
			               FROM Sale__c
			               WHERE Name='testSaleName0'];

			ServicePoint__c tServPoint=[SELECT Id, ServicePointCode__c, RecordType.DeveloperName, SupplyType__c, Account__c, SupplyProvince__c, SupplyTypeTemp__c
			                            FROM ServicePoint__c
			                            WHERE ServicePointCode__c='testServicePointCode'];


			ServicePoint__c tServPoint2=[SELECT Id, ServicePointCode__c, RecordType.DeveloperName, SupplyType__c, Account__c, SupplyProvince__c, SupplyTypeTemp__c
			                             FROM ServicePoint__c
			                             WHERE ServicePointCode__c='testServicePointCode2'];

			Map<String, Boolean> tcreateSale=HDT_LC_SaleServiceContainer.createSaleServiceItemTile(tServPoint2, tSale, tServPoint);

			System.debug('tcreateSale = '+tcreateSale);

			System.assertEquals(false, tcreateSale.isEmpty(), 'Return is wrong');
			System.assertNotEquals(true, tcreateSale.isEmpty(), 'createSaleServiceItemTile did not work correctly');
			Test.stopTest();
		}
	}

	@isTest
	public static void testupdateSale(){

		Test.startTest();

		Sale__c tSale=[SELECT Id, Name, CurrentStep__c
		               FROM Sale__c
		               WHERE Name='testSaleName0'];

		tSale.Name='testUpdate';

		HDT_LC_SaleServiceContainer.updateSale(tSale);

		Sale__c tSale2=[SELECT Id, Name
		                FROM Sale__c
		                WHERE Id=:tSale.Id];


		System.debug('tSale2 = '+tSale2);

		System.assertEquals('testUpdate', tSale2.Name, 'Sale not Updated');
		System.assertNotEquals('testSaleName0', tSale2.Name, 'updateSale did not work correctly');
		Test.stopTest();
	}
}