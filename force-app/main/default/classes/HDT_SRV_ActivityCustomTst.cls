/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/09/2021
 * @description Test Class for HDT_SRV_ActivityCustom.cls
 * @history Fabricio Petkevicius Nunes – 09/00/2021 – Created class
 */
@isTest
public class HDT_SRV_ActivityCustomTst{
	private static HDT_SRV_ActivityCustom activityCustomSrv=new HDT_SRV_ActivityCustom();
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstanceActivityIntegration();

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
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

			activityCustomSrv.checkAccessInit('BPCode__c, CausalError__c', 'create');

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

			activityCustomSrv.checkReadAccess('BPCode__c, CausalError__c');

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

			activityCustomSrv.checkCreateAccess('BPCode__c, CausalError__c');

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

			activityCustomSrv.checkUpdateAccess('BPCode__c, CausalError__c');

			Test.stopTest();
			// Method Return is VOID
			// System.assertEquals('', '', '');
			// System.assertNotEquals('', '');
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

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<wrts_prcgvr__Activity__c> activityCusts=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, tAccount[0].Id);

			wrts_prcgvr__Activity__c createdActivCust=activityCustomSrv.createRecord(activityCusts[0]);

			Test.stopTest();

			System.assertEquals(true, createdActivCust.Id!=null, 'Activity Custom not created');
			System.assertNotEquals(false, createdActivCust.Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	static void testCreateRecordList(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<wrts_prcgvr__Activity__c> activityCusts=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, tAccount[0].Id);

			List<wrts_prcgvr__Activity__c> createdActivCustList=activityCustomSrv.createRecord(activityCusts);

			Test.stopTest();

			System.assertEquals(false, createdActivCustList.isEmpty(), 'Activity Custom not created');
			System.assertNotEquals(true, createdActivCustList.isEmpty(), 'Value of parameter is not matching');
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

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<wrts_prcgvr__Activity__c> activityCusts=HDT_UTL_DataFactoryTst.createActivityCustom(1, true, tAccount[0].Id);

			activityCusts[0].CausalError__c='testError';

			activityCustomSrv.updateRecord(activityCusts[0]);

			Test.stopTest();

			List<wrts_prcgvr__Activity__c> updatedActivCust=[SELECT Id, CausalError__c
			                                                 FROM wrts_prcgvr__Activity__c
			                                                 WHERE CausalError__c='testError'];

			System.assertEquals('testError', updatedActivCust[0].CausalError__c, 'Activity Custom not updated');
			System.assertNotEquals('', updatedActivCust[0].CausalError__c, 'Value of parameter is not matching');
		}
	}
    
	@isTest static void testUpdateRecordList(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<wrts_prcgvr__Activity__c> activityCusts=HDT_UTL_DataFactoryTst.createActivityCustom(1, true, tAccount[0].Id);

			activityCusts[0].CausalError__c='testError';

			activityCustomSrv.updateRecords(activityCusts);

			Test.stopTest();

			List<wrts_prcgvr__Activity__c> updatedActivCust=[SELECT Id, CausalError__c
			                                                 FROM wrts_prcgvr__Activity__c
			                                                 WHERE CausalError__c='testError'];

			System.assertEquals('testError', updatedActivCust[0].CausalError__c, 'Activity Custom not updated');
			System.assertNotEquals('', updatedActivCust[0].CausalError__c, 'Value of parameter is not matching');
		}
	}
    
	@isTest static void testCreateRecordWithFieldCheck(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];

		System.runAs(u){

			Test.startTest();

			List<Account> tAccount=[SELECT Id, Name
			                        FROM Account 
			                        WHERE Name='test account0'
			                        LIMIT 1];

			List<wrts_prcgvr__Activity__c> activityCusts=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, tAccount[0].Id);

			List<wrts_prcgvr__Activity__c> createdActivCust=activityCustomSrv.createRecordWithFieldCheck(activityCusts);

			Test.stopTest();

			System.assertEquals(true, createdActivCust!=null, 'Activity Custom not created');
			System.assertNotEquals(false, createdActivCust!=null, 'Value of parameter is not matching');
		}
	}
}