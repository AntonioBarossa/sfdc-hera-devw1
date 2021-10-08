/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 06/09/2021
 * @description Test Class for HDT_SRV_AccountContactRelation.cls
 * @history Fabricio Petkevicius Nunes – 06/00/2021 – Created class
 */
@isTest
public class HDT_SRV_AccountContactRelationTst{
	private static HDT_SRV_AccountContactRelation accContRel=new HDT_SRV_AccountContactRelation();
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[1].Id);
		}
	}

	@isTest
	static void testCheckAccessInit(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			accContRel.checkAccessInit('IsActive, IsDirect', 'create');

			Test.stopTest();
			// Method Return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}
	}

	@isTest
	static void testCheckReadAccess(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			accContRel.checkReadAccess('IsActive, IsDirect');

			Test.stopTest();
			// Method Return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}
	}

	@isTest
	static void testCheckCreateAccess(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			accContRel.checkCreateAccess('IsActive, IsDirect');

			Test.stopTest();
			// Method Return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}
	}

	@isTest
	static void testCheckUpdateAccess(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			accContRel.checkUpdateAccess('IsActive, IsDirect');

			Test.stopTest();
			// Method Return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
		}
	}

	@isTest
	static void testUpdateRecord(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Account> tAccounts=[SELECT Id, Name
			                         FROM Account 
			                         WHERE Name='test account0'
			                         LIMIT 1];
			List<Contact> tContacts=[SELECT Id, FirstName
			                         FROM Contact
			                         WHERE FirstName='test'
			                         LIMIT 1];

			AccountContactRelation accConRels=HDT_UTL_DataFactoryTst.createAccountContactRelation(true, tAccounts[0].Id, tContacts[0].Id);

			accConRels.EndDate=Date.today().addDays(+20);

			AccountContactRelation updateAccConRel=accContRel.updateRecord(accConRels);

			Test.stopTest();

			System.assertEquals(Date.today().addDays(+20), updateAccConRel.EndDate, 'Account-Contact Relation not Updated');
			System.assertNotEquals(null, updateAccConRel.EndDate, 'Value of parameter is not matching');
		}
	}

	@isTest
	static void testCreateRecord(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Account> tAccounts=[SELECT Id, Name
			                         FROM Account 
			                         WHERE Name='test account0'
			                         LIMIT 1];
			List<Contact> tContacts=[SELECT Id, FirstName
			                         FROM Contact
			                         WHERE FirstName='test'
			                         LIMIT 1];

			AccountContactRelation accConRels=HDT_UTL_DataFactoryTst.createAccountContactRelation(false, tAccounts[0].Id, tContacts[0].Id);

			accConRels.EndDate=Date.today().addDays(+20);

			AccountContactRelation createAccConRel=accContRel.createRecord(accConRels);

			Test.stopTest();

			System.assertEquals(true, createAccConRel.Id!=null, 'Account-Contact Relation not Created');
			System.assertNotEquals(false, createAccConRel.Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	static void testUpsertRecord(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Account> tAccounts=[SELECT Id, Name
			                         FROM Account 
			                         WHERE Name='test account0'
			                         LIMIT 1];
			List<Contact> tContacts=[SELECT Id, FirstName
			                         FROM Contact
			                         WHERE FirstName='test'
			                         LIMIT 1];

			AccountContactRelation accConRels=HDT_UTL_DataFactoryTst.createAccountContactRelation(true, tAccounts[0].Id, tContacts[0].Id);

			accConRels.EndDate=Date.today().addDays(+20);

			List<AccountContactRelation> accConRelList=new List<AccountContactRelation>();
			accConRelList.add(accConRels);

			List<AccountContactRelation> upsertAccConRel=accContRel.upsertRecord(accConRelList);

			Test.stopTest();

			System.assertEquals(Date.today().addDays(+20), upsertAccConRel[0].EndDate, 'Account-Contact Relation not Upserted');
			System.assertNotEquals(null, upsertAccConRel[0].EndDate, 'Value of parameter is not matching');
		}
	}
}