/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 06/08/2021
 * @description HDT_UTL_Lead for Test Classes
 * @history Fabricio Petkevicius Nunes – 06/08/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_LeadTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){
			List<Lead> listLd=HDT_UTL_DataFactoryTst.createLead(1, false);
			listLd[0].Country='IT';
			listLd[0].IsAddressVerified__c=true;
			listLd[0].FirstName='testLead';

			insert listLd;
		}
	}

	@isTest
	public static void testGetAddressObject(){

		User u=[SELECT Id, Alias
		        FROM User
		        WHERE Alias='crmuser' AND Email='crmuser@test.com'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			Lead ld=[SELECT id, Company__c, Country, IsAddressVerified__c, StreetName__c
			         FROM Lead
			         WHERE Country='IT' AND FirstName='testLead'
			         LIMIT 1];

			HDT_WRP_AddressObject hdt=HDT_UTL_Lead.getAddressObject(ld.Id);

			System.debug('hdt = '+hdt);

			System.assertEquals(ld.StreetName__c, hdt.Civico, 'return is wrong');
			System.assertNotEquals(ld.Country, hdt.Civico, 'return is wrong');

			Test.stopTest();
		}
	}

	@isTest
	public static void testgetBlackListMap(){

		User u=[SELECT Id, Alias
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			Map<String, String> hdt=HDT_UTL_Lead.getBlackListMap();

			System.debug('hdt = '+hdt);

			System.assertEquals(true, hdt.isEmpty(), 'return is wrong');
			System.assertNotEquals(false, hdt.isEmpty(), 'return is wrong');

			Test.stopTest();
		}
	}

	@isTest
	public static void testupdateLead(){

		User u=[SELECT Id, Alias
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			Lead ld=[SELECT id, Company__c, Country
			         FROM Lead
			         WHERE Country='IT'
			         LIMIT 1];


			System.debug('ld = '+ld);

			ld.FirstName='testUpdate';

			HDT_UTL_Lead.updateLead(ld);

			Lead ldupdt=[SELECT id, Company__c, Country, FirstName
			             FROM Lead
			             WHERE Country='IT' AND FirstName='testUpdate'
			             LIMIT 1];

			System.debug('ldupdt = '+ldupdt);

			System.assertEquals('testUpdate', ldupdt.FirstName, 'Lead not updated');
			System.assertNotEquals('testLead', ldupdt.FirstName, 'Lead not updated');

			Test.stopTest();
		}
	}

	@isTest
	public static void testupdateLeadAddress(){

		User u=[SELECT Id, Alias
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			Lead ld=[SELECT id, Company__c, Country
			         FROM Lead
			         WHERE Country='IT'
			         LIMIT 1];

			Map<String, String> leads=new Map<String, String>();
			leads.put('Country', 'Stato');
			leads.put('State', 'Provincia');
			leads.put('City', 'Comune');

			boolean hdt=HDT_UTL_Lead.updateLeadAddress(ld.id, leads);

			System.debug('hdt = '+hdt);

			System.assertEquals(true, hdt, 'return is wrong');
			System.assertNotEquals(false, hdt, 'return is wrong');

			Test.stopTest();
		}
	}
}