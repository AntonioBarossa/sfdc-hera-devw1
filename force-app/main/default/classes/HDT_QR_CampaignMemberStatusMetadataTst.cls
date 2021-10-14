/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 27/07/2021
 * @description Test Class for HDT_QR_CampaignMemberStatusMetadata.cls
 * @history Fabricio Petkevicius Nunes – 27/07/2021 – Created class
 */
@isTest
public class HDT_QR_CampaignMemberStatusMetadataTst{
	@isTest
	static void testgetRecords(){

		Test.startTest();

		List<HDT_CampaignMemberStatus__mdt> campMembStatList=new List<HDT_CampaignMemberStatus__mdt>();
		HDT_CampaignMemberStatus__mdt campMembStat=[SELECT Id, DeveloperName, MasterLabel, Category__c, Channel__c, HasResponded__c, Default__c
		                                            FROM HDT_CampaignMemberStatus__mdt
		                                            WHERE MasterLabel='Nuovo'
		                                            LIMIT 1];

		System.debug('campMembStat = '+campMembStat);

		HDT_QR_CampaignMemberStatusMetadata.getRecords();


		System.assertEquals('Nuovo', campMembStat.MasterLabel, 'Campaign Member Status not correct');

		System.assertNotEquals('', campMembStat.MasterLabel,'value of parameter is not matching');

		Test.stopTest();
	}
}