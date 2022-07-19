/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 22/09/2021
 * @description HDT_UTL_Account Test Classes
 * @history Fabricio Petkevicius Nunes – 22/09/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_AccountTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_WS_HTTPServiceCallMock mock=new HDT_WS_HTTPServiceCallMock();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserRoleId=HDT_UTL_DataFactoryTst.getUserRoleId(constants.USERROLE_DEVELOPERNAME_BACKOFFICE);
		insert internalUser;

		HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, 'HDT_Archive', true);

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA', 'test.com', 'post', 'testUser');
			HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accounts[1].Id,'Bozza');
			AccountContactRelation myAccConRel =  HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accounts[1].Id, contacts[0].Id);
		}
	}

	@isTest
	public static void testCheckIsBackoffice(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			string checkIsBackOffice=HDT_UTL_Account.checkIsBackoffice();

			test.stopTest();

			System.assertEquals(true, checkIsBackOffice!=null, 'Return is wrong');
			System.assertNotEquals(false, checkIsBackOffice!=null, 'checkIsBackoffice did not work correclty');
		}
	}

	@isTest
	public static void testCallBpCaSearch(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, FiscalCode__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_WS_RicCreBpCaRequest callBpCaSearch=HDT_UTL_Account.callBpCaSearch(tAcc[0], tCon[0]);

			test.stopTest();

			System.assertEquals(true, callBpCaSearch!=null, 'Return is wrong');
			System.assertNotEquals(false, callBpCaSearch!=null, 'callBpCaSearch did not work correclty');
		}
	}

	@isTest
	public static void testCallBpCaCreate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c,CustomerCode__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_WS_RicCreBpCaRequest callBpCaCreate=HDT_UTL_Account.callBpCaCreate(tAcc[0], tCon[0]);

			test.stopTest();

			System.assertEquals(true, callBpCaCreate!=null, 'Return is wrong');
			System.assertNotEquals(false, callBpCaCreate!=null, 'callBpCaCreate did not work correclty');
		}
	}

	@isTest
	public static void testCallAmCaCreate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c,CustomerCode__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c, FirstName__c, LastName__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c, phone
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_WS_RicCreBpCaRequest callAmCaCreate=HDT_UTL_Account.callAmCaCreate(tAcc[0], tCon[0]);

			test.stopTest();

			System.assertEquals(true, callAmCaCreate!=null, 'Return is wrong');
			System.assertNotEquals(false, callAmCaCreate!=null, 'callAmCaCreate did not work correclty');
		}
	}

	@isTest
	public static void testMakeRequest(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			Test.setMock(HttpCalloutMock.class, mock);

			AccountContactRelation testAccConRel = [SELECT AccountId, ContactId, Roles, Account.Category__c FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, CustomerType__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c,CustomerCode__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c, FirstName__c, LastName__c
			                    FROM Account
			                    WHERE Id=:testAccConRel.AccountId];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c, phone
			                    FROM Contact
			                    WHERE Id=:testAccConRel.ContactId];

			testAccConRel.Roles = 'Amministratore condominio';
			update testAccConRel;
			
			HDT_UTL_Account.makeRequest(tAcc[0], tCon[0]);
			
			test.stopTest();

            List<Account> tResult = [SELECT Id, Code__c FROM Account WHERE Code__c = 'test' LIMIT 1];

			System.assertEquals(true, tResult!=null, 'Account not updated');
			System.assertNotEquals(false, tResult!=null, 'makeRequest did not work correclty');
		}
	}

	@isTest
	public static void testMassiveRequest(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			Test.setMock(HttpCalloutMock.class, mock);

			test.startTest();

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c,CustomerCode__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c, FirstName__c, LastName__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c, phone
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_UTL_Account.massiveRequest(tAcc[0], tCon[0]);

			test.stopTest();

			List<Account> tResult = [SELECT Id, Code__c,CustomerCode__c FROM Account WHERE CustomerCode__c = 'test' LIMIT 1];

			System.assertEquals(true, tResult!=null, 'Account not updated');
			System.assertNotEquals(false, tResult!=null, 'massiveRequest did not work correctly');
		}
	}
	@IsTest
	static void transcondeCustomerCategoryTst()
	{
		List<String> categoryList = new List<String>{'Famiglie','Aziende Soho','Aziende SME','Enti','Grandi Condomini','Intercompany','Salvaguardia Aziende','Salvaguardia Enti','Aziende TOP','Piccoli Condomini','Societa Vendita Terze','Default gas','Comuni Territorio','FUI domestico','FUI non domestico','Reseller - Gruppo','Reseller - Extra Gruppo'};
		List<String> resultList = new List<String>();
		for(String category : categoryList)
		{
			String result = HDT_UTL_Account.transcodeCustomerCategory(category);
			if(String.isNotBlank(result))
			{
				resultList.add(result);
			}
		}
		System.assertEquals(true, !resultList.isEmpty(), 'Transcodifica errata');
	}
	@isTesT
	static void createBpCaTst()
	{
		List<AccountContactRelation> acrList = [SELECT Id, Roles FROM AccountContactRelation WHERE Roles = 'Titolare'];
		List<Sale__c> saleList = [SELECT Id FROM Sale__c ];
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
			HDT_UTL_Account.createBpCa(acrList, saleList[0].Id, true);
		Test.stopTest();
		List<Account> accountTest = [SELECT Id FROM Account WHERE CustomerCode__c != NULL];
		System.assertEquals(true, !accountTest.isEmpty(), 'Account non assegnat');
	}
	@isTest
	static void checkCustomerMarkingTest()
	{
		List<String> customerMarking = new List<String>{'Persona fisica','Ditta individuale','Azienda','Parti comuni','Condominio','Associazione','BP Doppio','Marcatura nulla'};
		List<Account> accountTest = new List<Account>();
		String region = 'AQ';
		Test.startTest();
			for(String marking : customerMarking)
			{
				Account acc = new Account();
				acc.CustomerMarking__c = marking;
				acc = HDT_UTL_Account.checkCustomerMarking(acc, region);
				accountTest.add(acc);
			}
		Test.stopTest();
		System.assertEquals(true, !accountTest.isEmpty(), 'Marcatura non calcolata');
	}
	@IsTest
	static void registerCondominioTest()
	{
		List<Contact> contactList = [Select Id FROM Contact];
		List<Contact> contactTest = new List<Contact>();
		List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, false, 'HERA COMM', 'Condominio', 'Grandi Condomini');
		accList[0].CustomerCode__c = '10036162191';
		insert accList;
		AccountContactRelation acr = HDT_UTL_DataFactoryTst.createAccountContactRelation(false, accList[0].Id, contactList[0].Id);
		acr.Roles = 'Amministratore condominio';
		insert acr;
		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
			contactTest.add(HDT_UTL_Account.registerAmmCondominio(contactList[0],false));
		Test.stopTest();
		System.assertEquals(true, !contactTest.isEmpty(), 'Contatto non registrato');
	}

}