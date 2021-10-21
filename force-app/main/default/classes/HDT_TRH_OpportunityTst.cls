/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/09/2021
 * @description HDT_TRH_Opportunity Test Classes
 * @history Fabricio Petkevicius Nunes – 09/09/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_OpportunityTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@isTest
	public static void testOppBeforeInsert(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		System.runAs(internalUser){

			Test.startTest();

			List<Opportunity> opps=HDT_UTL_DataFactoryTst.createOpportunity(1, true);
			System.debug('opps = '+opps);

			Test.stopTest();

			List<Opportunity> createdOpp=[SELECT Id, Name
			                              FROM Opportunity 
			                              WHERE Name='testOpportunity0'
			                              LIMIT 1];

			System.assertEquals(true, createdOpp[0].Id!=null, 'Opportunity Not Created');
			System.assertNotEquals(false, createdOpp[0].Id!=null, 'Opportunity Not Created');
		}
	}
}