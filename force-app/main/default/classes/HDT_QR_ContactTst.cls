/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 19/07/2021
 * @description Test Class for HDT_QR_Contact.cls
 * @history Fabricio Petkevicius Nunes – 19/07/2021 – Created class
 */
@isTest
public class HDT_QR_ContactTst{
	@TestSetup
	static void setup(){

		List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
		HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);

	}

	@isTest
	static void testgetRecordById(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		Contact testContact=qrContact.getRecordById(tcon.Id);

		System.debug('testContact = '+testContact);


		System.assertEquals('test', testContact.FirstName, 'Contact First Name is wrong');

		System.assertNotEquals('', testContact.FirstName,'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordsById(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId, Company__c, CompanyOwner__c
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		
		
		Individual indTest=new Individual();
		indTest.LastName='test';

		insert indTest;

		tcon.IndividualId=indTest.Id;

		tcon.CompanyOwner__c='HERA COMM';
		tcon.Company__c='HC';

		upsert tcon;

		System.debug('tcon = '+tcon);


		List<string> idList=new List<String>();
		idList.add(tcon.Id);

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<Contact> testContactList=qrContact.getRecordsById(idList);

		System.debug('testContact = '+testContactList);


		System.assertEquals('HC', testContactList[0].Company__c, 'Contact Company is wrong');

		System.assertNotEquals('', testContactList[0].Company__c, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testPrimaryContactByAccount(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		tcon.Email='test@test.com';

		update tcon;

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<Contact> testContactList=qrContact.getPrimaryContactByAccount(tcon.AccountId);

		System.debug('testContact = '+testContactList);


		System.assertEquals('test@test.com', testContactList[0].Email, 'Contact Email is wrong');

		System.assertNotEquals('', testContactList[0].Email, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetContactsByAccount(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		tcon.Email='test@test.com';

		update tcon;

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<Contact> testContactList=qrContact.getContactsByAccount(tcon.AccountId);

		System.debug('testContact = '+testContactList);


		System.assertEquals(tcon.Id, testContactList[0].Id, 'Contact ID is wrong');

		System.assertNotEquals('', testContactList[0].Id, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetContactsIdByAccountId(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<String> testContactList=qrContact.getContactsIdByAccountId(tcon.AccountId);

		System.debug('testContact = '+testContactList);


		System.assertEquals(tcon.Id, testContactList[0], 'Contact ID is wrong');

		System.assertNotEquals('', testContactList[0], 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetContactsIdByAccountIdList(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		List<string> idList=new List<String>();
		idList.add(tcon.AccountId);

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<Contact> testContactList=qrContact.getContactsIdByAccountIdList(idList);

		System.debug('testContact = '+testContactList);


		System.assertEquals(tcon.Id, testContactList[0].Id, 'Contact ID is wrong');

		System.assertNotEquals('', testContactList[0].Id, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordsByIds(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		Set<Id> idSet=new Set<id>();
		idSet.add(tcon.Id);

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<Contact> testContactList=qrContact.getRecordsByIds(idSet);

		System.debug('testContact = '+testContactList);


		System.assertEquals(tcon.Id, testContactList[0].Id, 'Contact ID is wrong');

		System.assertNotEquals('', testContactList[0].Id, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetRecordByFiscalCode(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		tcon.FiscalCode__c='SXSRLA45H28H501K';

		update tcon;

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		Contact testContact=qrContact.getRecordByFiscalCode(tcon.FiscalCode__c);

		System.debug('testContact = '+testContact);


		System.assertEquals(tcon.Id, testContact.Id, 'Contact is wrong');

		System.assertNotEquals(null, testContact, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetContactsByOwnerId(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, Name, MailingLatitude, MailingLongitude, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		Id ownerId=UserInfo.getUserId();
		String ownerName=UserInfo.getUserName();

		System.Debug('ownerName = '+ownerName);

		tcon.OwnerId=ownerId;
		tcon.MailingLatitude=41.90396;
		tcon.MailingLongitude=12.479154999999999;
		tcon.LastName=ownerName;
		tcon.FirstName='';

		update tcon;

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<Contact> testContactList=qrContact.getContactsByOwnerId(ownerId, ownerName);

		System.debug('testContact = '+testContactList);


		System.assertEquals(tcon.LastName, testContactList[0].Name, 'Contact Name is wrong');

		System.assertNotEquals('', testContactList[0].Name, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetContactCoordinates(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];


		tcon.MailingLatitude=41.90396;
		tcon.MailingLongitude=12.479154999999999;

		update tcon;

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		Contact testContact=qrContact.getContactCoordinates(tcon.Id);

		System.debug('testContact = '+testContact);


		System.assertEquals(tcon.MailingLatitude, testContact.MailingLatitude, 'Contact Mailing Latitude is wrong');

		System.assertNotEquals(null, testContact.MailingLatitude, 'value of parameter is not matching');

		Test.stopTest();
	}

	@isTest
	static void testgetContactByEmailAddress(){

		Test.startTest();

		Contact tcon=[SELECT Id, FirstName, LastName, MobilePhone, Phone, Email, Fax, CertifiedEmail__c, IndividualId, FiscalCode__c, AccountId
		              FROM Contact
		              WHERE FirstName='test'
		              LIMIT 1];

		tcon.Email='test@test.com';

		update tcon;

		HDT_QR_Contact qrContact=new HDT_QR_Contact();

		List<Contact> testContactList=qrContact.getContactByEmailAddress(tcon.Email);

		System.debug('testContactList = '+testContactList);


		System.assertEquals(tcon.AccountId, testContactList[0].AccountId, 'Contact AccountId is wrong');

		System.assertNotEquals(null, testContactList[0].AccountId, 'value of parameter is not matching');

		Test.stopTest();
	}
}