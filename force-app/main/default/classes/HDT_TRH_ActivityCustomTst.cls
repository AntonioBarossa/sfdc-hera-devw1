/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 17/09/2021
 * @description HDT_TRH_ActivityCustom Test Classes
 * @history Fabricio Petkevicius Nunes – 17/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_ActivityCustomTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_TRH_ActivityCustom actCustTrigger = new HDT_TRH_ActivityCustom();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);
		HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();
	}

	@isTest
	public static void testTriggerActivityCustBeforeAfterInsert(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<wrts_prcgvr__Activity__c> activityCustom=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accounts[0].Id);
			activityCustom[0].DiscardCategory__c='Manuale';

			insert activityCustom;

			test.stopTest();

			List<wrts_prcgvr__Activity__c> tActCustomInsert=[SELECT Id, Account__c
			                                                 FROM wrts_prcgvr__Activity__c
			                                                 WHERE Id=:activityCustom[0].Id];

			System.assertEquals(true, tActCustomInsert[0].Account__c!=null, 'Activity Custom not created');
			System.assertNotEquals(false, tActCustomInsert[0].Account__c!=null, 'Activity Custom not created');
		}
	}

	@isTest
	public static void testTriggerActivityCustAfterUpdate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<wrts_prcgvr__Activity__c> activityCustom=HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accounts[0].Id);
			activityCustom[0].DiscardCategory__c='Manuale';

			update activityCustom;

			test.stopTest();

			List<wrts_prcgvr__Activity__c> tActCustomUpdate=[SELECT Id, DiscardCategory__c
			                                                 FROM wrts_prcgvr__Activity__c
			                                                 WHERE Id=:activityCustom[0].Id];

			System.assertEquals('Manuale', tActCustomUpdate[0].DiscardCategory__c, 'Activity Custom not Updated');
			System.assertNotEquals('', tActCustomUpdate[0].DiscardCategory__c, 'Activity Custom not Updated');
		}
	}

	@isTest
	public static void testTriggerActivityCustBeforeUpdate(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<wrts_prcgvr__Activity__c> activityCustom=HDT_UTL_DataFactoryTst.createActivityCustom(1, true, accounts[0].Id);
			activityCustom[0].DiscardCategory__c='Manuale';

			update activityCustom;

			test.stopTest();

			List<wrts_prcgvr__Activity__c> tActCustomUpdate=[SELECT Id, DiscardCategory__c
			                                                 FROM wrts_prcgvr__Activity__c
			                                                 WHERE Id=:activityCustom[0].Id];

			System.assertEquals('Manuale', tActCustomUpdate[0].DiscardCategory__c, 'Activity Custom not Updated');
			System.assertNotEquals('', tActCustomUpdate[0].DiscardCategory__c, 'Activity Custom not Updated');
		}
	}
	/*@isTest
	public static void testTriggerActivityCustUnusedContext(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

		//	actCustTrigger.afterDelete();
		//	actCustTrigger.beforeDelete();
			actCustTrigger.beforeUpdate();
		//	actCustTrigger.afterUndelete();

			// System.assertEquals();
			// System.assertNotEquals();
		}
	}*/

	@isTest
	public static void testCompanyName(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();
			List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
			accs[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Partner').getRecordTypeId();
			accs[0].CompanyOwner__c = null;
			update accs;
			//List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountDistributore(1, true, null, 'Azienda', 'Aziende SME'); 
			List<wrts_prcgvr__Activity__c> activityCustom=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accs[0].Id);
			

			insert activityCustom;

			test.stopTest();

			List<wrts_prcgvr__Activity__c> tActCustomInsert=[SELECT Id, Account__c,CompanyOwner__c
			                                                 FROM wrts_prcgvr__Activity__c
			                                                 WHERE Id=:activityCustom[0].Id];

			System.assertEquals(true, tActCustomInsert[0].CompanyOwner__c==Label.CompanyNameLabel, 'Activity Company Owner has not been updated');
			
		}
	}
	
}