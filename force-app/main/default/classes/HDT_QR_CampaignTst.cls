/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 23/08/2021
 * @description Test Class for HDT_QR_Campaign.cls
 * @history Fabricio Petkevicius Nunes – 23/08/2021 – Created class
 */
@isTest
public class HDT_QR_CampaignTst{
	@TestSetup
	static void setup(){

		List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(2, true);
		campaigns[1].ParentId=campaigns[0].Id;

		update campaigns;
	}

	@isTest
	static void testgetCampaignChild(){

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id
		                           FROM Campaign
		                           WHERE Name='Test Campaign'
		                           LIMIT 2];

		List<Id> idList=new List<Id>();
		idList.add(tCampaigns[0].id);
		idList.add(tCampaigns[1].id);

		List<Campaign> getCampChild=HDT_QR_Campaign.getCampaignChild(idList);

		Test.stopTest();

		System.assertEquals(false, getCampChild.isEmpty(), 'Child Campaign not found');
		System.assertNotEquals(true, getCampChild.isEmpty(),'value of parameter is not matching');
	}

	@isTest
	static void testgetCampaign(){

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id
		                           FROM Campaign
		                           WHERE Name='Test Campaign'
		                           LIMIT 2];

		List<Id> idList=new List<Id>();
		idList.add(tCampaigns[0].id);
		idList.add(tCampaigns[1].id);

		List<Campaign> getCampChild=HDT_QR_Campaign.getCampaign(idList);

		Test.stopTest();

		System.assertEquals(false, getCampChild.isEmpty(), 'Campaign not found');
		System.assertNotEquals(true, getCampChild.isEmpty(),'value of parameter is not matching');
	}

	@isTest
	static void testgetRecordById(){

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id
		                           FROM Campaign
		                           WHERE Name='Test Campaign'
		                           LIMIT 1];

		HDT_QR_Campaign campQuery=new HDT_QR_Campaign();

		Campaign campbyRecordId=campQuery.getRecordById(tCampaigns[0].Id);

		Test.stopTest();

		System.assertEquals('Test Campaign', campbyRecordId.Name, 'Campaign not found');
		System.assertNotEquals('', campbyRecordId.Name,'value of parameter is not matching');
	}

	@isTest
	static void testgetCampaignIds(){

		Test.startTest();

		List<Campaign> tGetCampId=HDT_QR_Campaign.getCampaignIds('Test Campaign');

		Test.stopTest();

		System.assertEquals(false, tGetCampId.isEmpty(), 'Campaign not found');
		System.assertNotEquals(true, tGetCampId.isEmpty(),'value of parameter is not matching');
	}

	@isTest
	static void testgetOutboundCampaigns(){

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id
		                           FROM Campaign
		                           WHERE Name='Test Campaign'
		                           LIMIT 1];

		tCampaigns[0].StartDate=Date.today().addDays(-1);
		tCampaigns[0].EndDate=Date.today().addDays(15);
		tCampaigns[0].Category__c='Campagna Outbound';
		tCampaigns[0].Channel__c='Telefonico Outbound';
		tCampaigns[0].IsActive=true;

		update tCampaigns;

		HDT_QR_Campaign campQuery=new HDT_QR_Campaign();

		List<Campaign> tGetOutbCamp=campQuery.getOutboundCampaigns();

		Test.stopTest();

		System.assertEquals(false, tGetOutbCamp.isEmpty(), 'Outbound Campaign not found');
		System.assertNotEquals(true, tGetOutbCamp.isEmpty(),'value of parameter is not matching');
	}

	@isTest
	static void testgetCampaignId(){

		Test.startTest();

		Campaign tGetCampId=HDT_QR_Campaign.getCampaignId('Test Campaign');

		Test.stopTest();

		System.assertEquals(true, tGetCampId!=null, 'Campaign not found');
		System.assertNotEquals(false, tGetCampId!=null,'value of parameter is not matching');
	}

	@isTest
	static void testgetSurveyCampaignById(){

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id, SurveyCRM__c, Name
		                           FROM Campaign 
		                           WHERE Name='Test Campaign'
		                           LIMIT 1];

		HDT_QR_Campaign campQuery=new HDT_QR_Campaign();

		Campaign campbySurveyCampId=campQuery.getSurveyCampaignById(tCampaigns[0].Id);

		Test.stopTest();

		System.assertEquals(true, campbySurveyCampId!=null, 'Campaign not found');
		System.assertNotEquals(false, campbySurveyCampId!=null,'value of parameter is not matching');
	}

	@isTest
	static void testgetCommercialCode(){

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id, SurveyCRM__c, Name
		                           FROM Campaign 
		                           WHERE Name='Test Campaign'
		                           LIMIT 2];

		tCampaigns[0].PrefixCode__c='test';

		update tCampaigns;

		HDT_QR_Campaign campQuery=new HDT_QR_Campaign();

		List<Campaign> campByCommCode=campQuery.getCommercialCode(tCampaigns[0].PrefixCode__c, tCampaigns[1].Id);

		Test.stopTest();

		System.assertEquals(false, campByCommCode.isEmpty(), 'Campaign not found');
		System.assertNotEquals(true, campByCommCode.isEmpty(),'value of parameter is not matching');
	}

	@isTest
	static void testgetCommercialCodeCampaign(){

		Test.startTest();

		List<Campaign> tCampaigns=[SELECT Id
		                           FROM Campaign
		                           WHERE Name='Test Campaign'
		                           LIMIT 1];

		HDT_QR_Campaign campQuery=new HDT_QR_Campaign();

		Campaign tGetCommCodeCamp=campQuery.getCommercialCodeCampaign(tCampaigns[0].Id);

		Test.stopTest();

		System.assertEquals(true, tGetCommCodeCamp.Id!=null, 'Campaign not found');
		System.assertNotEquals(false, tGetCommCodeCamp.Id!=null,'value of parameter is not matching');
	}
}