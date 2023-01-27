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

		internal.LoginChannel__c  = 'Back office';
		internal.CreatorGroup__c = 'HC_CRM_CC_OUT_KN'; 
		internal.Station__c = 'CC_KN_Supporti';

		insert internal;

        
        List<PermissionSetAssignment> permissionAssignments = new List<PermissionSetAssignment>(); 
        permissionAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internal, constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false));
        permissionAssignments.add(HDT_UTL_DataFactoryTst.assignPermissionSet(internal, constantsUtl.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false));

        insert permissionAssignments;

		System.runAs(internal){

			HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			// List<Account> accList=HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');

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


	@IsTest
	static void testSetUsersField(){

        User u = [SELECT Id, CreatorGroup__c, LoginChannel__c, Station__c FROM User WHERE Alias = 'crmuser' LIMIT 1];
		List<Sale__c> saleList = new List<Sale__c>();
		List<Account> accounts = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1];

		Test.startTest();
		
			System.runAs(u){
			 	saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accounts[0].Id, 'Bozza');						
			}

			List<Sale__c> sales = [SELECT Id, CreatorGroup__c, LoginGroup__c, LoginWorkstation__c FROM Sale__c WHERE Id =: saleList[0].Id WITH SECURITY_ENFORCED LIMIT 1];
			System.assertEquals(true, sales[0].LoginGroup__c != null && sales[0].LoginGroup__c != '', 'Gruppo di login non valorizzato');
			System.assertEquals(true, sales[0].LoginGroup__c == u.LoginChannel__c, 'Gruppo di login diverso');
			System.assertEquals(true, sales[0].CreatorGroup__c != null && sales[0].CreatorGroup__c != '', 'Gruppo Creatore non valorizzato');
			System.assertEquals(true, sales[0].CreatorGroup__c == u.CreatorGroup__c, 'Gruppo Creatore diverso');
			System.assertEquals(true, sales[0].LoginWorkstation__c != null && sales[0].LoginWorkstation__c != '', 'Postazione di login non valorizzata');
			System.assertEquals(true, sales[0].LoginWorkstation__c == u.Station__c, 'Postazione di login diversa');	

		Test.stopTest();
		
	}

	@IsTest
	static void exctrPhaseTransDateFromStory(){
		String phaseStory = 'Documentazione Validata@@Ammissibilità OK@@1663575122289@@A||Accettazione Voltura@@In attesa validazione@@1663575087285@@A||Da Inviare@@Accettazione Voltura@@1663575026402@@A||Bozza@@Da Inviare@@1663574640395@@A||';
		Date datePhase = HDT_UTL_Utils.exctrPhaseTransDateFromStory(phaseStory, 'Documentazione Validata');
		System.assertEquals(null, datePhase, 'Calcolo exctrPhaseTransDateFromStory non valido');
		phaseStory = 'Documentazione Validata@@Ammissibilità OK@@1663575122289@@A||In attesa validazione@@Documentazione Validata@@1663575122289@@A||Accettazione Voltura@@In attesa validazione@@1663575087285@@A||Da Inviare@@Accettazione Voltura@@1663575026402@@A||Bozza@@Da Inviare@@1663574640395@@A||';
		datePhase = HDT_UTL_Utils.exctrPhaseTransDateFromStory(phaseStory, 'Documentazione Validata');
		System.assert(datePhase != null, 'Calcolo exctrPhaseTransDateFromStory non valido');
	}

	@IsTest
	static void testBeforeSapPhase(){
		String response = '';
		Test.startTest();
			response = HDT_UTL_Utils.beforeSapPhase('Errore Lavorazione SAP', '');
			System.assertEquals('', response, 'Calcolo non valido quando la story è vuota');
			response = HDT_UTL_Utils.beforeSapPhase('Errore Lavorazione SAP', 'Errore tecnico invio a SAP@@Errore Lavorazione SAP@@1669487910967@@A||Errore Lavorazione SAP@@Errore tecnico invio a SAP@@1669404356152@@M||Ammissibilità OK@@Errore Lavorazione SAP@@1659117263912@@A||');
			System.assertEquals('Ammissibilità OK', response, 'Calcolo non valido caso 1');
			response = HDT_UTL_Utils.beforeSapPhase('Errore Lavorazione SAP', 'Errore tecnico invio a SAP@@Errore Lavorazione SAP@@1669487910967@@A||');
			System.assertEquals('', response, 'Calcolo non valido caso 2');
			response = HDT_UTL_Utils.beforeSapPhase('Errore Lavorazione SAP', 'Errore tecnico invio a SAP@@Bozza@@1669487910967@@A||Errore Lavorazione SAP@@Errore tecnico invio a SAP@@1669404356152@@M||Ammissibilità OK@@Errore Lavorazione SAP@@1659117263912@@A||');
			System.assertEquals('', response, 'Calcolo non valido caso 3');
		Test.stopTest();
	}
}