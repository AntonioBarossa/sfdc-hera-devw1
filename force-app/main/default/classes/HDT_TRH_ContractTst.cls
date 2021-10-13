/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/08/2021
 * @description HDT_TRH_Contract for Test Classes
 * @history Fabricio Petkevicius Nunes – 9/08/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_ContractTst{
	
	//DATA
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	
	
	//TEST SETUP
	
	
	//TESTS
	
	//ALSO TESTING SERVICES ON HDT_UTL_ActiveServicesKpi.updateServicesCount;
	@isTest
	public static void beforeAfterInsertTest_EnergiaElettrica(){
		
		//SETUP
		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Energia Elettrica';
		insert servPoint;
		
		//TESTING
		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();
		
		//RETRIEVING DATA
		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesEle__c FROM Account];
		System.debug('testContract = ' + testContract);
		System.debug('testAccount = ' + testAccount);
		
		//ASSERTS
		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesEle__c, 'Active Services Ele errato.');
	}
	
	
	@isTest
	public static void beforeAfterInsertTest_Gas(){
		
		//SETUP
		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Gas';
		insert servPoint;
		
		//TESTING
		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();
		
		//RETRIEVING DATA
		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesGas__c FROM Account];
		System.debug('testContract = ' + testContract);
		System.debug('testAccount = ' + testAccount);
		
		//ASSERTS
		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesGas__c, 'Active Services Gas errato.');
	}
	
	
	
	@isTest
	public static void beforeAfterInsertTest_TLR(){
		
		//SETUP
		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Teleriscaldamento';
		insert servPoint;
		
		//TESTING
		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();
		
		//RETRIEVING DATA
		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesTLR__c FROM Account];
		System.debug('testContract = ' + testContract);
		System.debug('testAccount = ' + testAccount);
		
		//ASSERTS
		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesTLR__c, 'Active Services TLR errato.');
	}
	
	
	@isTest
	public static void beforeAfterInsertTest_Water(){
		
		//SETUP
		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Acqua';
		insert servPoint;
		
		//TESTING
		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();
		
		//RETRIEVING DATA
		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesWater__c FROM Account];
		System.debug('testContract = ' + testContract);
		System.debug('testAccount = ' + testAccount);
		
		//ASSERTS
		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesWater__c, 'Active Services Water errato.');
	}
	
	
	@isTest
	public static void beforeAfterInsertTest_Waste(){
		
		//SETUP
		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Ambiente';
		insert servPoint;
		
		//TESTING
		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();
		
		//RETRIEVING DATA
		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesWaste__c FROM Account];
		System.debug('testContract = ' + testContract);
		System.debug('testAccount = ' + testAccount);
		
		//ASSERTS
		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesWaste__c, 'Active Services Waste errato.');
	}
	
	

	@isTest
	public static void testTriggerContractBeforeAfterUpdate(){

		Test.startTest();

		List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].Id);

		contracts[0].BillingCountry='IT';

		update contracts;

		System.debug('contracts = '+contracts);

		Contract testContract=[SELECT Id, SAPContractCode__c, BillingCountry
		                       FROM Contract
		                       WHERE SAPContractCode__c='3011913470' and BillingCountry='IT'
		                       LIMIT 1];

		System.assertEquals('IT', testContract.BillingCountry, 'Contract not Updated');
		System.assertNotEquals('', testContract.BillingCountry, 'Contract not Updated');
		Test.stopTest();
	}

	@isTest
	public static void testTriggerContractBeforeAfterDelete(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;
		internalUser.Title='srTest';

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			Test.startTest();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id);

			contracts[0].BillingCountry='BR';

			insert contracts;

			System.debug('contracts = '+contracts);

			Contract testContract=[SELECT Id, SAPContractCode__c, BillingCountry, IsDeleted
			                       FROM Contract
			                       WHERE SAPContractCode__c='3011913470' AND BillingCountry='BR'
			                       LIMIT 1];


			delete testContract;

			System.debug('testcontract = '+testContract);

			Contract testContract2=[SELECT Id, SAPContractCode__c, BillingCountry, IsDeleted
			                        FROM Contract
			                        WHERE Id=:testcontract.Id ALL ROWS];

			System.assertEquals(true, testContract2.IsDeleted, 'Contract not deleted');
			System.assertNotEquals(false, testContract2.IsDeleted, 'Contract not deleted');
			Test.stopTest();
		}
	}
}