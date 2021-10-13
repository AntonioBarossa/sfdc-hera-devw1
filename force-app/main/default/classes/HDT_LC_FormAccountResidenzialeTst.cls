/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 20/07/2021
 * @description Test Class for HDT_LC_FormAccountResidenziale.cls
 * @history Fabricio Petkevicius Nunes – 20/07/2021 – Created class
 */
@isTest
public class HDT_LC_FormAccountResidenzialeTst{
	@TestSetup
	static void setup(){

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		accList[0].FirstName__c='test';
		accList[0].BillingCityCode__c='RO';
		insert accList;

		List<Contact> conList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);

		System.debug('SETUPaccList = '+accList);
		System.debug('SETUPconList = '+conList);
	}

	@isTest
	static void testinsertAccount(){

		Test.startTest();

		List<Account> tacc=[SELECT Id, Name, LastName__c, RecordTypeId, FiscalCode__c, CustomerMarking__c, Category__c, CompanyOwner__c, BillingStreetName__c, BillingCityCode__c, BillingStreetNumber__c
		                    FROM Account
		                    WHERE Name='test account0'
		                    LIMIT 1];


		System.debug('tacc = '+tacc);


		Map<String, String> dataAccount=new Map<String, String>{'firstName'=>'test', 'recordTypeId'=>tacc[0].RecordTypeId, 'fiscalCode'=>tacc[0].FiscalCode__c, 'customerMarking'=>tacc[0].CustomerMarking__c, 'category'=>tacc[0].Category__c, 'companyOwner'=>tacc[0].CompanyOwner__c, 'name'=>tacc[0].Name, 'lastName'=>tacc[0].LastName__c, 'role' => 'admin'};

		Map<String, String> accountAddress=new Map<String, String>{'billingCity'=>'Roma', 'billingStreetName__c'=>tacc[0].BillingStreetName__c, 'billingCityCode__c'=>tacc[0].BillingCityCode__c, 'billingStreetNumber__c'=>'21'};
		Account accTest=HDT_LC_FormAccountResidenziale.insertAccount(dataAccount, accountAddress);


		System.debug('dataAccount = '+dataAccount);

		System.debug('accTest = '+accTest);


		System.assertEquals(tacc[0].FiscalCode__c, accTest.FiscalCode__c, 'Account Fiscal Code is wrong');

		System.assertNotEquals(null, accTest.FiscalCode__c, 'insertAccount did not work correctly');

		Test.stopTest();
	}
}