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

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA', 'test.com', 'post', 'testUser');
			HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
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
			System.assertNotEquals(false, checkIsBackOffice!=null);
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

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_WS_RicCreBpCaRequest callBpCaSearch=HDT_UTL_Account.callBpCaSearch(tAcc[0], tCon[0]);

			test.stopTest();

			System.assertEquals(true, callBpCaSearch!=null, 'Return is wrong');
			System.assertNotEquals(false, callBpCaSearch!=null);
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

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetToponym__c, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_WS_RicCreBpCaRequest callBpCaCreate=HDT_UTL_Account.callBpCaCreate(tAcc[0], tCon[0]);

			test.stopTest();

			System.assertEquals(true, callBpCaCreate!=null, 'Return is wrong');
			System.assertNotEquals(false, callBpCaCreate!=null);
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

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetToponym__c, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c, FirstName__c, LastName__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c, phone
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_WS_RicCreBpCaRequest callAmCaCreate=HDT_UTL_Account.callAmCaCreate(tAcc[0], tCon[0]);

			test.stopTest();

			System.assertEquals(true, callAmCaCreate!=null, 'Return is wrong');
			System.assertNotEquals(false, callAmCaCreate!=null);
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

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetToponym__c, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c, FirstName__c, LastName__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c, phone
			                    FROM Contact
			                    WHERE FirstName='test'];

			HDT_UTL_Account.makeRequest(tAcc[0], tCon[0]);

			test.stopTest();

            List<Account> tResult = [SELECT Id, Code__c FROM Account WHERE Code__c = 'test' LIMIT 1];

			System.assertEquals(true, tResult!=null, 'Account not updated');
			System.assertNotEquals(false, tResult!=null);
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

			List<Account> tAcc=[SELECT Id, Name, RecordTypeId, Category__c, customerMarking__c, vatnumber__c, fax, fiscalCode__c, BillingCity, BillingCountry, BillingStreetToponym__c, BillingStreetNumber__c, BillingPostalCode, BillingState, BillingStreetName__c, Code__c, MobilePhone__c, BuildingFloor__c, PrimaryEmail__c, VATGroup__c, VATGroupStartDate__c, VATGroupEndDate__c, FirstName__c, LastName__c
			                    FROM Account
			                    WHERE Name='test account0'];

			List<Contact> tCon=[SELECT Id, FirstName, MobilePhone, email, fiscalCode__c, CertifiedEmail__c, phone
			                    FROM Contact
			                    WHERE FirstName='test'];

			Account massiveReq=HDT_UTL_Account.massiveRequest(tAcc[0], tCon[0]);

			test.stopTest();

			List<Account> tResult = [SELECT Id, Code__c FROM Account WHERE Code__c = 'test' LIMIT 1];

			System.assertEquals(true, tResult!=null, 'Account not updated');
			System.assertNotEquals(false, tResult!=null);
		}
	}
}