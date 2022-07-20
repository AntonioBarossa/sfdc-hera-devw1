/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 12/08/2021
 * @description HDT_LC_FormAccountBusiness for Test Classes
 * @history Fabricio Petkevicius Nunes – 12/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_FormAccountBusinessTst{
	public static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static Map<String, String> tDataAccount=new Map<String, String>();
	private static Map<String, String> tAccountAddress=new Map<String, String>();
	private static Map<String, String> tContactAddress=new Map<String, String>();
	private static HDT_WS_HTTPServiceCallMock mock=new HDT_WS_HTTPServiceCallMock();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;
		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{ HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false) };
		permissionSetAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, 'HDT_Archive', false));
		insert permissionSetAssignments;

		System.runAs(internalUser){
			HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA', 'test.com', 'post', 'testUser');
			HDT_UTL_DataFactoryTst.createWebServiceCredential('testUser', '12345', 'usernameTest');
			HDT_UTL_DataFactoryTst.createCity();
		}
	}

	@isTest
	public static void testinsertAccount(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.setMock(HttpCalloutMock.class, mock);
			Test.startTest();

			Id rtIdBusiness=constants.ACCOUNT_RECORDTYPEID_BUSINESS;

			// AccountAddress Map
			tAccountAddress.put('billingCountry', 'IT');
			tAccountAddress.put('BillingIsAddressVerified__c', 'true');

			//ContactAddress Map
			tContactAddress.put('MailingIsAddressVerified__c','true');

			//AAcoountData Map
			tDataAccount.put('companyOwner', 'HERA COMM');
			tDataAccount.put('customerMarking', 'Azienda');
			tDataAccount.put('category', 'Aziende SME');
			tDataAccount.put('customerTypeValue', 'Gruppo');
			tDataAccount.put('recordTypeId', rtIdBusiness);
			tDataAccount.put('email', 'test@test.com');
			tDataAccount.put('vatNumber', '07988320011');
			tDataAccount.put('fiscalCode', 'TSTTTC05B47H501Y');
			tDataAccount.put('legalForm', 'Consorzi di Impresa');
			tDataAccount.put('firstIndividualName', 'FirstNameTst');
			tDataAccount.put('lastIndividualName', 'LastNameTst');
			tDataAccount.put('businessName', 'LastNameTst');
			tDataAccount.put('customerTypeValue', 'Organizzazione');
			tDataAccount.put('birthPlace', 'Roma');
			tDataAccount.put('birthplace', 'Roma');
			tDataAccount.put('firstName', 'TestAcc1');
			tDataAccount.put('lastName', 'testcontactform');
			tDataAccount.put('mobilePhone', '21312312312');
			tDataAccount.put('contactPhoneNumber', '21312312312');
			tDataAccount.put('role', 'Titolare');
			tDataAccount.put('mobilephoneNumber', '21312312312');
			tDataAccount.put('phoneNumber', '21312312312');
			tDataAccount.put('electronicMail', 'test@test.com');
			tDataAccount.put('contactEmail', 'test@test.com');
			tDataAccount.put('gender', 'Femmina');
			tDataAccount.put('birthDate', String.valueOf(Date.today().addMonths(-200)));

			String fiscalCode=HDT_UTL_CalculateFiscalCode.calculateFiscalCode(tDataAccount);
			tDataAccount.put('personFiscalCode', fiscalCode);

			Account tReturn=HDT_LC_FormAccountBusiness.insertAccount(tDataAccount, tAccountAddress, tContactAddress);

			System.assertEquals(false, tReturn.Id==null, 'Account not created');
			System.assertNotEquals(true, tReturn.Id==null, 'Account not created');

			Test.stopTest();

		}
	}

	@isTest
	public static void testinsertAccountPerson(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.setMock(HttpCalloutMock.class, mock);
			Test.startTest();

			Id rtIdResidenziale=constants.ACCOUNT_RECORDTYPEID_RESINDEZIALE;

			// AccountAddress Map
			tAccountAddress.put('billingCountry', 'IT');
			tAccountAddress.put('BillingIsAddressVerified__c', 'true');

			//ContactAddress Map
			tContactAddress.put('MailingIsAddressVerified__c','true');

			//AcoountData Map
			tDataAccount.put('companyOwner', 'HERA COMM');
			tDataAccount.put('customerMarking', 'Persona Fisica');
			tDataAccount.put('category', 'Famiglie');
			tDataAccount.put('customerTypeValue', 'Gruppo');
			tDataAccount.put('recordTypeId', rtIdResidenziale);
			tDataAccount.put('email', 'test@test.com');
			tDataAccount.put('vatNumber', '02682500166');
			tDataAccount.put('fiscalCode', 'TSTTTC05B46H501W');
			tDataAccount.put('legalForm', 'Consorzi di Impresa');
			tDataAccount.put('businessName', 'LastNameTst');
			tDataAccount.put('firstIndividualName', 'FirstNameTst');
			tDataAccount.put('lastIndividualName', 'LastNameTst');
			tDataAccount.put('birthPlace', 'Roma');
			tDataAccount.put('birthplace', 'Roma');
			tDataAccount.put('firstName', 'FirstNameTst LastNameTst');
			tDataAccount.put('lastName', 'LastNameTst');
			tDataAccount.put('mobilePhone', '21312312312');
			tDataAccount.put('contactPhoneNumber', '21312312312');
			tDataAccount.put('role', null);
			tDataAccount.put('mobilephoneNumber', '21312312312');
			tDataAccount.put('phoneNumber', '21312312312');
			tDataAccount.put('electronicMail', 'test@test.com');
			tDataAccount.put('contactEmail', 'test@test.com');
			tDataAccount.put('gender', 'Femmina');
			tDataAccount.put('birthDate', String.valueOf(Date.today().addMonths(-200)));

			String fiscalCode=HDT_UTL_CalculateFiscalCode.calculateFiscalCode(tDataAccount);
			tDataAccount.put('personFiscalCode', fiscalCode);

			Account tReturn=HDT_LC_FormAccountBusiness.insertAccount(tDataAccount, tAccountAddress, tContactAddress);

			System.assertEquals(false, tReturn.Id==null, 'Account not created');
			System.assertNotEquals(true, tReturn.Id==null, 'Account not created');

			Test.stopTest();
		}
	}

	@isTest
	public static void testinsertAccountNoPhone(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.setMock(HttpCalloutMock.class, mock);
			Test.startTest();

			Id rtIdBusiness=constants.ACCOUNT_RECORDTYPEID_BUSINESS;

			// AccountAddress Map
			tAccountAddress.put('billingCountry', 'IT');
			tAccountAddress.put('BillingIsAddressVerified__c', 'true');

			//ContactAddress Map
			tContactAddress.put('MailingIsAddressVerified__c','true');

			//AAcoountData Map
			tDataAccount.put('companyOwner', 'HERA COMM');
			tDataAccount.put('customerMarking', 'Azienda');
			tDataAccount.put('category', 'Aziende SME');
			tDataAccount.put('customerTypeValue', 'Gruppo');
			tDataAccount.put('recordTypeId', rtIdBusiness);
			tDataAccount.put('email', 'test@test.com');
			tDataAccount.put('vatNumber', '05724831002');
			tDataAccount.put('fiscalCode', 'TSTTTC05B47H501Y');
			tDataAccount.put('legalForm', 'Consorzi di Impresa');
			tDataAccount.put('businessName', 'LastNameTst');
			tDataAccount.put('firstIndividualName', 'FirstNameTst');
			tDataAccount.put('lastIndividualName', 'LastNameTst');
			tDataAccount.put('customerTypeValue', 'Organizzazione');
			tDataAccount.put('businessName', 'LastNameTst');
			tDataAccount.put('birthPlace', 'Roma');
			tDataAccount.put('birthplace', 'Roma');
			tDataAccount.put('firstName', 'TestAcc1');
			tDataAccount.put('lastName', 'testcontactform');
			tDataAccount.put('mobilePhone', '21312312312');
			tDataAccount.put('role', 'Titolare');
			tDataAccount.put('mobilephoneNumber', '21312312312');
			tDataAccount.put('phoneNumber', '21312312312');
			tDataAccount.put('gender', 'Femmina');
			tDataAccount.put('birthDate', String.valueOf(Date.today().addMonths(-200)));

			String fiscalCode=HDT_UTL_CalculateFiscalCode.calculateFiscalCode(tDataAccount);
			tDataAccount.put('personFiscalCode', fiscalCode);

			Account tReturn=HDT_LC_FormAccountBusiness.insertAccount(tDataAccount, tAccountAddress, tContactAddress);

			System.assertEquals(false, tReturn.Id==null, 'Account not created');
			System.assertNotEquals(true, tReturn.Id==null, 'Account not created');

			Test.stopTest();
		}
	}
	@IsTest
	static void testInsertAccountWithExistingContact()
	{
		List<Account> accRes = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'Persona fisica', 'Famiglie');
		List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accRes[0].Id);
		// AccountAddress Map
		Id rtIdBusiness=constants.ACCOUNT_RECORDTYPEID_BUSINESS;

		// AccountAddress Map
		tAccountAddress.put('billingCountry', 'IT');
		tAccountAddress.put('BillingIsAddressVerified__c', 'true');

		//ContactAddress Map
		tContactAddress.put('MailingIsAddressVerified__c','true');

		//AAcoountData Map
		tDataAccount.put('companyOwner', 'HERA COMM');
		tDataAccount.put('customerMarking', 'Azienda');
		tDataAccount.put('category', 'Aziende SME');
		tDataAccount.put('customerTypeValue', 'Gruppo');
		tDataAccount.put('recordTypeId', rtIdBusiness);
		tDataAccount.put('email', 'test@test.com');
		tDataAccount.put('vatNumber', '05724831002');
		tDataAccount.put('fiscalCode', 'TSTTTC05B47H501Y');
		tDataAccount.put('legalForm', 'Consorzi di Impresa');
		tDataAccount.put('businessName', 'LastNameTst');
		tDataAccount.put('firstIndividualName', 'FirstNameTst');
		tDataAccount.put('lastIndividualName', 'LastNameTst');
		tDataAccount.put('customerTypeValue', 'Organizzazione');
		tDataAccount.put('businessName', 'LastNameTst');
		tDataAccount.put('birthPlace', 'Roma');
		tDataAccount.put('birthplace', 'Roma');
		tDataAccount.put('firstName', 'TestAcc1');
		tDataAccount.put('lastName', 'testcontactform');
		tDataAccount.put('mobilePhone', '21312312312');
		tDataAccount.put('role', 'Titolare');
		tDataAccount.put('mobilephoneNumber', '21312312312');
		tDataAccount.put('phoneNumber', '21312312312');
		tDataAccount.put('gender', 'Femmina');
		tDataAccount.put('birthDate', String.valueOf(Date.today().addMonths(-200)));

		String fiscalCode=HDT_UTL_CalculateFiscalCode.calculateFiscalCode(tDataAccount);
		tDataAccount.put('personFiscalCode', fiscalCode);
		contactList[0].FiscalCode__c = fiscalCode;
		insert contactList;

		Test.setMock(HttpCalloutMock.class, mock);
		Test.startTest();
		Account tReturn=HDT_LC_FormAccountBusiness.insertAccount(tDataAccount, tAccountAddress, tContactAddress);
		Test.stopTest();
		
		System.assertEquals(false, tReturn.Id==null, 'Account not created');
		System.assertNotEquals(true, tReturn.Id==null, 'Account not created');
	}
}