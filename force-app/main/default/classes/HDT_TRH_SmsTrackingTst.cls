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
			HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].Id);

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

			List<SMSTracking__c> smsTracks=new List<SMSTracking__c>();
			SMSTracking__c smsTrack=new SMSTracking__c();
			smsTrack.FromName__c='testSms';
			smsTrack.CompanyOwner__c='HERA COMM';
			smsTrack.ContactID__c=tContact[0].Id;
			smsTrack.ActionDateTime__c=Datetime.newInstance(2021, 11, 11, 11, 30, 0);
			smsTrack.MessageID__c=12321421;
			smsTrack.Mobile__c='234234234';
			smsTrack.MobileMessageTrackingID__c=12343143;
			smsTrack.ModifiedDateTime__c=Datetime.newInstance(2021, 11, 11, 11, 30, 0);

			smsTracks.add(smsTrack);

			insert smsTracks;

			Test.stopTest();

			SMSTracking__c testSmsTracking=[SELECT Id, FromName__c
			                                FROM SMSTracking__c
			                                WHERE FromName__c='testSms'
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

			List<Contact> tContact=[SELECT Id, CompanyOwner__c
			                        FROM Contact
			                        WHERE CompanyOwner__c='HERA COMM'
			                        LIMIT 1];

			Test.startTest();

			List<SMSTracking__c> smsTracks=new List<SMSTracking__c>();
			SMSTracking__c smsTrack=new SMSTracking__c();
			smsTrack.FromName__c='testSms';
			smsTrack.CompanyOwner__c='HERA COMM';
			smsTrack.ContactID__c=tContact[0].Id;
			smsTrack.ActionDateTime__c=Datetime.newInstance(2021, 11, 11, 11, 30, 0);
			smsTrack.MessageID__c=12321421;
			smsTrack.Mobile__c='234234234';
			smsTrack.MobileMessageTrackingID__c=12343143;
			smsTrack.ModifiedDateTime__c=Datetime.newInstance(2021, 11, 11, 11, 30, 0);

			smsTracks.add(smsTrack);

			insert smsTracks;

			smsTracks[0].Name__c='test';

			update smsTracks;

			Test.stopTest();

			SMSTracking__c testSmsTracking=[SELECT Id, Name__c, FromName__c
			                                FROM SMSTracking__c
			                                WHERE FromName__c='testSms'
			                                LIMIT 1];

			System.assertEquals('test', testSmsTracking.Name__c, 'SmsTracking not Updated');
			System.assertNotEquals('', testSmsTracking.Name__c, 'SmsTracking not Updated');

		}
	}
}