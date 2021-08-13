/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 10/08/2021
 * @description HDT_LC_RecordEditFormSales for Test Classes
 * @history Fabricio Petkevicius Nunes – 10/08/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_RecordEditFormSalesTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@testSetup
	static void setup(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.HERA_SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			Id rt=constants.CASE_RECORDTYPEID_MOROSITA;

			HDT_UTL_DataFactoryTst.pClickInstance();
			HDT_UTL_DataFactoryTst.pClickCasePhase();
			HDT_UTL_DataFactoryTst.pClickOrderPhase();

			HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato', 'Bozza', rt, 'HDT_RT_Morosita');
			HDT_UTL_DataFactoryTst.newPhaseTransition('In Lavorazione', 'Bozza', rt, 'HDT_RT_Morosita');
			HDT_UTL_DataFactoryTst.newPhaseTransition('Completata', 'In Lavorazione', rt, 'HDT_RT_Morosita');

			List<Account> accounts=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].id, 'Attiva');
			List<ServicePoint__c> servpoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
			List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, accounts[0].id);
			List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, accounts[0].id);
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, accounts[0].id, 'Bozza');
			List<Case> cases=HDT_UTL_DataFactoryTst.createCase(2, false, accounts[0].id, contacts[0].Id, servpoints[0].Id, contracts[0].Id, orders[0].Id);
			cases[1].HerokuPracticeCode__c='12341234123456';
			insert cases;
			List<wrts_prcgvr__Activity__c> activities=HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accounts[0].id);
			activities[0].Case__c=cases[0].Id;
			activities[0].wrts_prcgvr__status__c='Completed';

			insert activities;

			cases[0].Activity__c=activities[0].Id;

			update cases;
		}
	}

	@isTest
	public static void testcancelCase(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;
		internalUser.Title='srTest';

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			Test.startTest();

			Case tCase=[SELECT Id, HerokuPracticeCode__c
			            FROM Case
			            WHERE HerokuPracticeCode__c='21313232132132'];

			HDT_LC_RecordEditFormSales.cancelCase(tCase.Id);

			Case tCancelCase=[SELECT Id, Phase__c, Status
			                  FROM Case
			                  WHERE Id=:tCase.Id];

			System.assertEquals('Annullato', tCancelCase.Phase__c, 'Case not cancelled');
			System.assertNotEquals('Bozza', tCancelCase.Phase__c);
			Test.stopTest();
		}
	}

	@isTest
	public static void testgetActivity(){

		Test.startTest();

		Case tCase=[SELECT Id, HerokuPracticeCode__c
		            FROM Case
		            WHERE HerokuPracticeCode__c='21313232132132'];


		wrts_prcgvr__Activity__c tCustActivity=HDT_LC_RecordEditFormSales.getActivity(tCase.Id);

		System.debug('tCustActivity = '+tCustActivity);

		System.assertEquals(true, String.isNotEmpty(tCustActivity.Id), ' wrong Custom Activity returned');
		System.assertNotEquals(false, String.isNotEmpty(tCustActivity.Id));
		Test.stopTest();
	}

	@isTest
	public static void testconfirmForApproval(){

		Test.startTest();

		Account tAccount=[SELECT Id, FiscalCode__c
		                  FROM Account
		                  WHERE FiscalCode__c='SXSRLA45H28H501K'];

		Case tCase=[SELECT Id, HerokuPracticeCode__c
		            FROM Case
		            WHERE HerokuPracticeCode__c='12341234123456'];


		Boolean confirm=HDT_LC_RecordEditFormSales.confirmForApproval(tCase.Id, tAccount.Id);

		System.debug('confirm = '+confirm);

		System.assertEquals(false, confirm, 'Custom Activity not returned');
		System.assertNotEquals(true, confirm);
		Test.stopTest();
	}

	@isTest
	public static void testsavePractice(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];


		System.runAs(u){

			Test.startTest();

			Contract tContract=[SELECT Id, SAPContractCode__c
			                    FROM Contract
			                    WHERE SAPContractCode__c='3011913470'
			                    LIMIT 1];

			Account tAccount=[SELECT Id, FiscalCode__c
			                  FROM Account
			                  WHERE FiscalCode__c='SXSRLA45H28H501K'];

			Case tCase=[SELECT Id, HerokuPracticeCode__c
			            FROM Case
			            WHERE HerokuPracticeCode__c='12341234123456'];

			Case tCase2=[SELECT Id, HerokuPracticeCode__c
			             FROM Case
			             WHERE HerokuPracticeCode__c='21313232132132'];


			Map<String, Object> caseobj=New Map<string, Object>();
			caseobj.put('Contract__c', tContract.Id);
			caseobj.put('OperationSubType__c', 'Prezzo energia negoziato');
			caseobj.put('ReassignmentReason__c', 'Attesa approvazione');
			caseobj.put('OperationType__c', 'Unificazione CA');

			HDT_LC_RecordEditFormSales.savePractice(tCase.Id, tAccount.Id, caseobj);
			HDT_LC_RecordEditFormSales.savePractice(tCase2.Id, tAccount.Id, caseobj);


			Case tCaseUpdt=[SELECT Id, Phase__c
			                FROM Case
			                WHERE Id=:tCase.Id];

			System.assertEquals('In Lavorazione', tCaseUpdt.Phase__c, 'Case not updated');
			System.assertNotEquals('Bozza', tCaseUpdt.Phase__c);
			Test.stopTest();
		}
	}

	@isTest
	public static void testsaveDraft(){

		User u=[SELECT Id
		        FROM User
		        WHERE Alias='crmuser'
		        LIMIT 1];


		System.runAs(u){

			Test.startTest();

			Contract tContract=[SELECT Id, SAPContractCode__c
			                    FROM Contract
			                    WHERE SAPContractCode__c='3011913470'
			                    LIMIT 1];

			Account tAccount=[SELECT Id, FiscalCode__c
			                  FROM Account
			                  WHERE FiscalCode__c='SXSRLA45H28H501K'];

			Case tCase=[SELECT Id, HerokuPracticeCode__c
			            FROM Case
			            WHERE HerokuPracticeCode__c='21313232132132'];


			Map<String, Object> caseobj=New Map<string, Object>();
			caseobj.put('Contract__c', tContract.Id);
			caseobj.put('OperationSubType__c', 'Prezzo energia negoziato');
			caseobj.put('ReassignmentReason__c', 'Attesa approvazione');
			caseobj.put('OperationType__c', 'Unificazione CA');

			HDT_LC_RecordEditFormSales.saveDraft(tCase.Id, tAccount.Id, caseobj);

			Case tCaseUpdt=[SELECT Id, ReassignmentReason__c
			                FROM Case
			                WHERE Id=:tCase.Id];

			System.assertEquals('Attesa approvazione', tCaseUpdt.ReassignmentReason__c, 'Case not updated');
			System.assertNotEquals('', tCaseUpdt.ReassignmentReason__c);

			Test.stopTest();
		}
	}
}