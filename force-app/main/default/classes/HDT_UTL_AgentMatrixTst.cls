/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 17/09/2021
 * @description HDT_UTL_AgentMatrix Test Classes
 * @history Fabricio Petkevicius Nunes – 17/09/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_AgentMatrixTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<AgentMatrix__c> agentMatrix=HDT_UTL_DataFactoryTst.createAgentMatrix(1, false, 'Telefono');
			agentMatrix[0].IsMonitoring__c=true;
			agentMatrix[0].AgencyCode__c='testCode';

			insert agentMatrix;
		}
	}

	@isTest
	public static void testAgencyCodeIsMonitoringList(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<String> agencyCodeisMonitoringList=HDT_UTL_AgentMatrix.agencyCodeIsMonitoringList();

			test.stopTest();

			System.assertEquals('testCode', agencyCodeisMonitoringList[0], 'AgencyCode not returned');
			System.assertNotEquals(true, agencyCodeisMonitoringList.isEmpty());
		}
	}
}