/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 27/07/2021
 * @description Test Class for HDT_QR_CampaignMemberStatusMetadata.cls
 * @history Fabricio Petkevicius Nunes – 27/07/2021 – Created class
 */
@isTest
public class HDT_QR_CampaignMemberStatusMetadataTst{

	//TEST SETUP
    private static void mySetup(){
		HDT_CampaignMemberStatus__mdt myMdt = HDT_CampaignMemberStatus__mdt.getInstance('ANSWERING_MACHINE_BY_AGENT');
	}


	@isTest
	static void testgetRecords(){

		Test.startTest();

		HDT_CampaignMemberStatus__mdt campMembStat=[SELECT Id, DeveloperName, MasterLabel, Category__c, Channel__c, HasResponded__c, Default__c
		                                            FROM HDT_CampaignMemberStatus__mdt
		                                            WHERE MasterLabel='ANSWERING_MACHINE_BY_AGENT'
		                                            LIMIT 1];

		HDT_QR_CampaignMemberStatusMetadata.getRecords();


		System.assertEquals('ANSWERING_MACHINE_BY_AGENT', campMembStat.MasterLabel, 'Campaign Member Status not correct');

		System.assertNotEquals('', campMembStat.MasterLabel, 'Campaign Member Status not correct');

		Test.stopTest();
	}
}