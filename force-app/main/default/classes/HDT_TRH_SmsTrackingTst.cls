/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 08/09/2021
 * @description HDT_TRH_SmsTracking Test Classes
 * @history Fabricio Petkevicius Nunes – 08/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_SmsTrackingTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		System.runAs(internalUser){

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);
			HDT_UTL_DataFactoryTst.createSmsTracking(1, true, contacts[0].Id);

		}
	}

	@isTest
	public static void testTriggerSmsTrackingBeforeInsert(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			List<Contact> tContact=[SELECT Id, CompanyOwner__c
			                        FROM Contact
			                        WHERE CompanyOwner__c='HERA COMM'
			                        LIMIT 1];

			Test.startTest();

			SMSTracking__c track = HDT_UTL_DataFactoryTst.createSmsTracking(1, true, tContact[0].Id).get(0);

			Test.stopTest();

			SMSTracking__c testSmsTracking=[SELECT Id, FromName__c
			                                FROM SMSTracking__c
			                                WHERE Id =: track.Id
			                                LIMIT 1];

			System.assertEquals(true, testSmsTracking.Id!=null, 'SmsTracking not Inserted');
			System.assertNotEquals(false, testSmsTracking.Id!=null, 'SmsTracking not Inserted');

		}
	}

	@isTest
	public static void testTriggerSmsTrackingAfterUpdate(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			SMSTracking__c smsTrack = [SELECT Id, Name__c FROM SMSTracking__c LIMIT 1];

			Test.startTest();			

			smsTrack.Name__c='test';

			update smsTrack;

			Test.stopTest();

			SMSTracking__c testSmsTracking=[SELECT Id, Name__c, FromName__c
			                                FROM SMSTracking__c
			                                WHERE Id =: smsTrack.Id
			                                LIMIT 1];

			System.assertEquals('test', testSmsTracking.Name__c, 'SmsTracking not Updated');
			System.assertNotEquals('', testSmsTracking.Name__c, 'SmsTracking not Updated');

		}
	}
}