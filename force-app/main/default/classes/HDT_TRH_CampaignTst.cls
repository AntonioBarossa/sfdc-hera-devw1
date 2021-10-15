/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 09/08/2021
 * @description HDT_TRH_Campaign for Test Classes
 * @history Fabricio Petkevicius Nunes – 9/08/2021 – Created class
 */
@isTest
public with sharing class HDT_TRH_CampaignTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@isTest
	public static void testBeforeInsertBeforeUpdate(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, constants.PERMISSIONSET_HDT_APEXCLASSES, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){

			Test.startTest();

			List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(1, false);
			campaigns[0].Status='Pianificata';

			insert campaigns;

			campaigns[0].IsActive=true;
			campaigns[0].CodeConventionQuantity__c=1;
			campaigns[0].CodeManagementModel__c='Convenzione';
			campaigns[0].CodeGenerationRule__c='PrefissoProgressivo';
			campaigns[0].Status='In Corso';

			update campaigns;

			List<Campaign> updatedCampaign = [SELECT Id, Status FROM Campaign WHERE Status = 'In Corso' LIMIT 1];

			System.assertEquals('In Corso', updatedCampaign[0].Status, 'Campaign Not Updated');
			System.assertNotEquals('Pianificata', updatedCampaign[0].Status, 'Campaign Not Updated');

			Test.stopTest();
		}
	}
}