/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 17/09/2021
 * @description HDT_UTL_BrandSalesCompany Test Classes
 * @history Fabricio Petkevicius Nunes – 17/09/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_BrandSalesCompanyTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<BrandSalesCompany__c> brandSalesCo=HDT_UTL_DataFactoryTst.createBrandSalesCompany(1, false);
			brandSalesCo[0].CommonSupply__c='testCommomSupply';
			brandSalesCo[0].Service__c='testService';
			brandSalesCo[0].SalesCompany__c='testSalesCo';
			brandSalesCo[0].MarketType__c='testMarketType';
			brandSalesCo[0].ActiveFlgforACR__c=true;
			brandSalesCo[0].ActiveFlgforBrand__c=true;
			brandSalesCo[0].CorporateBrand__c='testCorpBrand';

			insert brandSalesCo;
		}
	}

	@isTest
	public static void testGetFieldsMatrice(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			String fieldsMatrice=HDT_UTL_BrandSalesCompany.getFieldsMatrice('testCommomSupply', 'testService', 'testSalesCo', 'testMarketType');

			HDT_UTL_BrandSalesCompany.getFieldsMatrice('testKO', 'testKO', 'testKO', 'testKO');

			test.stopTest();

			System.assertEquals('testCorpBrand', fieldsMatrice, 'CorporateBrand not returned');
			System.assertNotEquals('', fieldsMatrice, 'getFieldsMatrice did not work correctly');
		}
	}
}