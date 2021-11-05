/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 22/09/2021
 * @description HDT_UTL_QuoteProcess Test Classes
 * @history Fabricio Petkevicius Nunes – 22/09/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_QuoteProcessTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(2, false, 'HERA COMM', 'Azienda', 'Aziende SME');
			accounts[1].VATNumber__c='12345678';
			accounts[1].FiscalCode__c='SXSRLA45H28H5';
			insert accounts;

			List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Attiva');
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].Id, 'Bozza');

			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			List<SBQQ__Quote__c> quotes=HDT_UTL_DataFactoryTst.createQuote(2, false, orders[0].Id, opps[0].Id, sales[0].Id, 'Amendment');
			quotes[0].BrandLogo__c='testLogo';
			quotes[0].SBQQ__Account__c=accounts[0].Id;
			quotes[0].ContractReference__c=contracts[0].Id;
			quotes[0].SBQQ__MasterContract__c=contracts[0].Id;
			quotes[0].AmendmentAllowed__c=true;
			quotes[0].SBQQ__Status__c='Accepted';
			quotes[0].SBQQ__Status__c='In Review';

			quotes[1].BrandLogo__c='testLogo1';
			quotes[1].SBQQ__Account__c=accounts[1].Id;
			quotes[1].ContractReference__c=contracts[0].Id;
			quotes[1].SBQQ__MasterContract__c=contracts[0].Id;
			quotes[1].AmendmentAllowed__c=true;
			quotes[1].SBQQ__Type__c='Quote';
			quotes[1].SBQQ__Status__c='Amendment';
			quotes[1].SBQQ__Opportunity2__c=opps[0].Id;
			quotes[1].FriendCode__c='testeNewQuote';

			insert quotes;

			HDT_UTL_DataFactoryTst.createSaleServiceItem(1, true, opps[0].Id, quotes[0].Id, servPoints[0].Id);
		}
	}

	@isTest
	public static void testAmendProcessManagementBefore(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<SBQQ__Quote__c> tQuote=[SELECT Id, BrandLogo__c, SaleBy__c, SupplyCity__c, Market__c, SalesCompany__c, FriendCode__c, Agency__c, SBQQ__Quote__c.Channel__c, SBQQ__Type__c, SBQQ__Account__c, SBQQ__MasterContract__c, ContractReference__c, SBQQ__Opportunity2__c, Sale__c, SBQQ__Status__c, AmendmentAllowed__c, SBQQ__Quote__c.Campaign__c
			                             FROM SBQQ__Quote__c
			                             WHERE BrandLogo__c='testLogo'];

			List<SBQQ__Quote__c> tQuote1=[SELECT Id, isTransition__c, CreatedBy__c, CampaignCode__c, SBQQ__Primary__c, SalesCompanyCode__c, BrandLogo__c, SaleBy__c, 
                                                 SupplyCity__c, Market__c, SalesCompany__c, FriendCode__c, Agency__c, SBQQ__Quote__c.Channel__c, SBQQ__Type__c, SBQQ__Account__c, 
                                          		 SBQQ__MasterContract__c, ContractReference__c, SBQQ__Opportunity2__c, Sale__c, SBQQ__Status__c, AmendmentAllowed__c, 
                                          		 SBQQ__Quote__c.Campaign__c, AllowChangeUse__c, UseCategory__c, ConsumptionRangeEE__c, ConsumptionRangeGAS__c, PowerFlow__c,
                                          		 MarketOrigin__c, ResidentDeliveryAddress__c, MeterType__c, SupplyProvince__c, Login__c, LoginGroup__c, Role__c, NewClient__c,
                                          		 SuperUser__c, SBQQ__PricebookId__c
			                              FROM SBQQ__Quote__c
			                              WHERE BrandLogo__c='testLogo1'];
            
			List<SaleServiceItem__c> tSaleServItem=[SELECT Id, Quote__c, Opportunity__c, Quote__r.SBQQ__Status__c
			                                        FROM SaleServiceItem__c
			                                        WHERE Quote__c=:tQuote];

			Map<String, SBQQ__Quote__c> mapOldtoNew=new Map<String, SBQQ__Quote__c>();
			mapOldtoNew.put(tQuote[0].Id, tQuote[0]);

			HDT_UTL_QuoteProcess.updateItems(mapOldToNew, tSaleServItem);
			HDT_UTL_QuoteProcess.assignValueToNewQuote(tQuote[0], tQuote1[0]);

			test.stopTest();

			List<SaleServiceItem__c> tSaleServItemUpdate=[SELECT Id, Quote__c, Opportunity__c
			                                              FROM SaleServiceItem__c
			                                              WHERE Quote__c=:tQuote[0].Id AND Opportunity__c=:tQuote[0].SBQQ__Opportunity2__c];

			System.assertEquals(false, tSaleServItemUpdate.isEmpty(), 'SaleServiceItem not updated wrong');
			System.assertNotEquals(true, tSaleServItemUpdate.isEmpty(), 'SaleServiceItem not updated');
		}
	}
}