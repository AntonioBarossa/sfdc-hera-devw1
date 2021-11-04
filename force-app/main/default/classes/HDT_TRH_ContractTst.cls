/**
 * Header of the class "HDT_TRH_ContractTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_TRH_Contract"
 * @history
 * @Created 12/10/2021
 * Modified By:
 **/
@isTest
public with sharing class HDT_TRH_ContractTst{

	@isTest
	public static void testUpdate(){

		Test.startTest();

		List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		HDT_UTL_DataFactoryTst.createContract(1, true, accs[0].Id);
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1,true,accs[0].id,'Bozza');               
        
        Contract contr = [Select Id from contract limit 1];
        contr.SBQQ__Order__c = orders[0].id;
        
        update contr;
        
        Test.stopTest();
        
        List<Contract> query = [Select id,SBQQ__Order__c from contract];

		System.assertEquals(1, query.size(), 'Contract not inserted correctly');
		System.assertNotEquals(null, query[0].SBQQ__Order__c, 'Contract not updated correctly');
  
  }

	@isTest
	public static void beforeAfterInsertTestEnergiaElettrica(){

		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Energia Elettrica';
		insert servPoint;

		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();

		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesEle__c FROM Account];

		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesEle__c, 'Active Services Ele errato.');
	}
	
	
	@isTest
	public static void beforeAfterInsertTestGas(){
		
		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Gas';
		insert servPoint;

		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();

		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesGas__c FROM Account];

		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesGas__c, 'Active Services Gas errato.');
	}
	
	
	
	@isTest
	public static void beforeAfterInsertTestTlr(){

		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Teleriscaldamento';
		insert servPoint;

		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();

		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesTLR__c FROM Account];

		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesTLR__c, 'Active Services TLR errato.');
	}
	
	
	@isTest
	public static void beforeAfterInsertTestWater(){

		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Acqua';
		insert servPoint;

		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();

		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesWater__c FROM Account];

		System.assertEquals('3011913470', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertNotEquals('', testContract.SAPContractCode__c, 'Contract not Inserted');
		System.assertEquals(1, testAccount.ActiveServicesWater__c, 'Active Services Water errato.');
	}
	
	
	@isTest
	public static void beforeAfterInsertTestWaste(){
	
		List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		ServicePoint__c servPoint = HDT_UTL_DataFactoryTst.createServicePoint(1, false)[0];
		servPoint.CommoditySector__c = 'Ambiente';
		insert servPoint;
		
		Test.startTest();
		Contract con = HDT_UTL_DataFactoryTst.createContract(1, false, accounts[0].Id)[0];
		con.ServicePoint__c = servPoint.Id;
		insert con;
		
		Test.stopTest();
		
		Contract testContract = [SELECT Id, SAPContractCode__c FROM Contract WHERE SAPContractCode__c = '3011913470' LIMIT 1];
		Account testAccount = [SELECT Id, ActiveServicesWaste__c FROM Account];

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


		Contract testContract=[SELECT Id, SAPContractCode__c, BillingCountry
		                       FROM Contract
		                       WHERE SAPContractCode__c='3011913470' and BillingCountry='IT'
		                       LIMIT 1];

		System.assertEquals('IT', testContract.BillingCountry, 'Contract not Updated');
		System.assertNotEquals('', testContract.BillingCountry, 'Contract not Updated');
		Test.stopTest();    
	}
}