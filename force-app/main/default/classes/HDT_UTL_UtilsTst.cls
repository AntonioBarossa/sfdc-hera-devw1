/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 05/08/2021
 * @description Test Class for HDT_UTL_Utils.cls
 * @history Fabricio Petkevicius Nunes – 05/08/2021 – Created class
 */
@isTest
public class HDT_UTL_UtilsTst{

	private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    private static HDT_UTL_Utils utils = new HDT_UTL_Utils();
	
	@TestSetup
	static void setup(){

		User internal = HDT_UTL_DataFactoryTst.createInternalUser(HDT_UTL_DataFactoryTst.getProfileId(constantsUtl.SYSTEM_ADMINISTRATOR_NAME), false);
		internal.UserRoleId = HDT_UTL_DataFactoryTst.getUserRoleId(constantsUtl.USERROLE_DEVELOPERNAME_BACKOFFICE);

		insert internal;
        
        List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>(); 
        permissionAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internal, constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false));
        permissionAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internal, constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false));

        insert permissionAssignments;

		System.runAs(internal){

			HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

		}
    }

	@isTest
	static void testcreateMapFromSobjectList(){

		Test.startTest();

		List<SObject> accTst=[SELECT Id, CompanyOwner__c, Category__c, Name, Description
		                      FROM Account
		                      WHERE CompanyOwner__c='HERA COMM'
		                      LIMIT 1];


		HDT_UTL_Utils utilsTest=new HDT_UTL_Utils();

		Schema.SObjectField fieldToken=Account.Name;

		Map<String, sObject> testReturn=utilsTest.createMapFromSobjectList(accTst, fieldToken);


		System.debug('accTst = '+accTst);
		System.debug('testReturn = '+testReturn);


		System.assertEquals(false, testReturn.isEmpty(), 'Return is wrong');

		System.assertNotEquals(true, testReturn.isEmpty(), 'Return is wrong');

		Test.stopTest();
	}

	@isTest
	static void testcodingSha256(){

		Test.startTest();

		String stringTst='testString';

		string testReturn=HDT_UTL_Utils.codingSha256(stringTst);


		System.debug('testReturn = '+testReturn);


		System.assertEquals(true, testReturn.isAlphanumeric(), 'Return is wrong');

		System.assertNotEquals(false, testReturn.isAlphanumeric(), 'Return is wrong');

		Test.stopTest();
	}

	@IsTest
	static void test (){

		User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];
		
		Test.startTest();

			System.runAs(u){
				
				HDT_UTL_Utils.getCurrentUserRole();
				System.assertEquals(HDT_UTL_Utils.getCurrentUserRole(), constantsUtl.USERROLE_DEVELOPERNAME_BACKOFFICE, 'The UserRole Developer names don\'t mach');
			}

		Test.stopTest();
		
	}

	@IsTest
	static void testisAssignedCustomPermission(){

        User u = [SELECT Id FROM User WHERE Alias = 'crmuser' LIMIT 1];
		
		Test.startTest();
		
			System.runAs(u){
				
				system.assertEquals(utils.isAssignedCustomPermission(constantsUtl.CUSTOMPERMISSION_NAME_SALESFORCECPQADMIN), true, 'Expected Custom permission not found');
			}

		Test.stopTest();
		
	}
}