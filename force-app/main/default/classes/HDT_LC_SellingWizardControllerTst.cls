/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 14/09/2021
 * @description HDT_LC_SellingWizardController Test Class
 * @history Fabricio Petkevicius Nunes – 14/09/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_SellingWizardControllerTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){
			HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		}
	}

	@isTest
	public static void testGetAccount(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccs=[SELECT Id, Name, LastName__c
			                     FROM Account];

			Account tAccount=HDT_LC_SellingWizardController.getAccount(tAccs[0].Id, 'Name, LastName__c');

			Test.stopTest();

			System.assertEquals(true, tAccount.Id!=null, 'Account not found');
			System.assertNotEquals(false, tAccount.Id!=null, 'getAccount did not work correctly');
		}
	}

	@isTest
	public static void testGetSale(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccs=[SELECT Id, Name, LastName__c
			                     FROM Account];

			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, tAccs[0].Id, 'Attiva');

			Sale__c tSale=HDT_LC_SellingWizardController.getSale(sales[0].Id, 'Name, Status__c, Account__c');

			Test.stopTest();

			System.assertEquals(true, tSale.Id!=null, 'Sale not found');
			System.assertNotEquals(false, tSale.Id!=null, 'getSale did not work correctly');
		}
	}

	@isTest
	public static void testCheckCommunityLogin(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			Boolean check=HDT_LC_SellingWizardController.checkCommunityLogin();

			Test.stopTest();

			System.assertEquals(false, check, 'Check is wrong');
			System.assertNotEquals(true, check, 'checkCommunityLogin did not work correctly');
		}
	}

	@isTest
	public static void testCreateSale(){

		User tUser=[SELECT Id, Alias
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.startTest();

			List<Account> tAccs=[SELECT Id, Name, LastName__c
			                     FROM Account];

			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, false, tAccs[0].Id, 'Attiva');

			Sale__c tSale=HDT_LC_SellingWizardController.createSale(sales[0]);

			Test.stopTest();

			System.assertEquals(true, tSale.Id!=null, 'Sale not created');
			System.assertNotEquals(false, tSale.Id!=null, 'createSale did not work correctly');
		}
	}
}