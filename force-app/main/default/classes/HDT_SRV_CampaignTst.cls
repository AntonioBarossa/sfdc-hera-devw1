/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 26/07/2021
 * @description Test Class for HDT_SRV_Campaign.cls
 * @history Fabricio Petkevicius Nunes – 26/07/2021 – Created class
 */
@isTest
public class HDT_SRV_CampaignTst{
	@TestSetup
	static void setup(){

		Id profileId=[SELECT Id
		              FROM Profile
		              WHERE Name='Marketing User'].Id;

		User crmUser=new User(Alias='crmuser', FirstName='FirstName', LastName='LastName', Email='crmuser@test.com', EmailEncodingKey='UTF-8', LanguageLocaleKey='it', LocaleSidKey='it', ProfileId=profileId, TimeZoneSidKey='Europe/Rome', UserName='herauser@test.com'+DateTime.now().getTime(), UserPermissionsMarketingUser=true, IsActive=true);
	}

	@isTest
	static void testinsertCampaigns(){

		Test.startTest();

		User tUser=[SELECT Id, FirstName
		            FROM USER
		            WHERE UserPermissionsMarketingUser=true AND IsActive=true
		            LIMIT 1];

		System.debug('tUser = '+tUser);

		System.runAs(tUser){

			List<Campaign> campaignList=new List<Campaign>();
			Campaign campaign=new Campaign();
			Campaign.Name='test';

			campaignList.add(campaign);

			List<Campaign> testCampaignList=HDT_SRV_Campaign.insertCampaigns(campaignList);


			System.debug('testCampaignList = '+testCampaignList);

			System.assertEquals('test', testCampaignList[0].Name, 'Campaign was not created correctly');

			System.assertNotEquals('', testCampaignList[0].Name, 'Value of parameter is not matching');

		}

		Test.stopTest();
	}

	@isTest
	static void testupdateCampaigns(){

		Test.startTest();

		User tUser=[SELECT Id, FirstName
		            FROM USER
		            WHERE UserPermissionsMarketingUser=true AND IsActive=true
		            LIMIT 1];

		System.debug('tUser = '+tUser);

		System.runAs(tUser){

			List<Campaign> campaignList=new List<Campaign>();
			Campaign campaign=new Campaign();
			Campaign.Name='test';

			campaignList.add(campaign);

			insert campaignList;

			campaign.Name='testUpd';

			List<Campaign> testCampaignList=HDT_SRV_Campaign.updateCampaigns(campaignList);


			System.debug('testCampaignList = '+testCampaignList);

			System.assertEquals('testUpd', testCampaignList[0].Name, 'Campaign was not updated correctly');

			System.assertNotEquals('', testCampaignList[0].Name, 'Value of parameter is not matching');

		}

		Test.stopTest();
	}
}