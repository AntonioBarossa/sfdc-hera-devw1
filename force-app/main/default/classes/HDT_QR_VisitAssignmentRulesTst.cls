/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 14/09/2021
 * @description Test Class for HDT_QR_VisitAssignmentRules.cls
 * @history Fabricio Petkevicius Nunes – 14/09/2021 – Created class
 */
@isTest
public class HDT_QR_VisitAssignmentRulesTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<VisitAssignmentRules__c> visitAssignmentRulesList=HDT_UTL_DataFactoryTst.createVisitAssignmentRules(1, false);
			visitAssignmentRulesList[0].Cap__c='testCap';
			visitAssignmentRulesList[0].Category__c='Azienda';
			visitAssignmentRulesList[0].Consumption__c='SMALL: EE<300.000 | gas<50.000';

			insert visitAssignmentRulesList;
		}
	}

	@isTest
	public static void testGetSurveys(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<VisitAssignmentRules__c> tVisitAssigRulesList=[SELECT Id, Name
			                                                    FROM VisitAssignmentRules__c 
			                                                    WHERE Name='testName'];

			VisitAssignmentRules__c tVisitAssigRules=HDT_QR_VisitAssignmentRules.getRecordById(tVisitAssigRulesList[0].Id);

			test.stopTest();

			System.assertEquals(true, tVisitAssigRules.Id!=null, 'VisitAssignmentRules not found');
			System.assertNotEquals(false, tVisitAssigRules.Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetAssignmentConfigurations(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<VisitAssignmentRules__c> tVisitAssigRules=HDT_QR_VisitAssignmentRules.getAssignmentConfigurations('testCap', 'Azienda', 'SMALL: EE<300.000 | gas<50.000');

			test.stopTest();

			System.assertEquals(true, tVisitAssigRules[0].Id!=null, 'VisitAssignmentRules not found');
			System.assertNotEquals(false, tVisitAssigRules[0].Id!=null, 'Value of parameter is not matching');
		}
	}
}