/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 14/09/2021
 * @description Test Class for HDT_QR_SurveyCrm.cls
 * @history Fabricio Petkevicius Nunes – 14/09/2021 – Created class
 */
@isTest
public class HDT_QR_SurveyCrmTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<SurveyCRM__c> surveyCrmList=HDT_UTL_DataFactoryTst.createSurveyCrm(1, true);
			List<Campaign> campaigns=HDT_UTL_DataFactoryTst.createCampaign(1, false);
			campaigns[0].SurveyCRM__c=surveyCrmList[0].Id;

			insert campaigns;
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

			List<Campaign> tCampaign=[SELECT Id, Name
			                          FROM Campaign 
			                          WHERE Name='Test Campaign'];

			List<String> campIds=new List<String>();
			campIds.add(tCampaign[0].Id);

			List<SurveyCRM__c> tSurveyCrm=HDT_QR_SurveyCrm.getSurveys(campIds, 'Name , Question1__c');

			test.stopTest();

			System.assertEquals(true, tSurveyCrm[0].Id!=null, 'SurveyCrm not found');
			System.assertNotEquals(false, tSurveyCrm[0].Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetSurvey(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<SurveyCRM__c> tSurveyCrmList=[SELECT Id, Name, Question1__c
			                                   FROM SurveyCRM__c
			                                   WHERE Name='testName'];

			List<SurveyCRM__c> tSurveyCrm=HDT_QR_SurveyCrm.getSurvey(tSurveyCrmList[0].Id, 'Name , Question1__c');

			test.stopTest();

			System.assertEquals(true, tSurveyCrm[0].Id!=null, 'SurveyCrm not found');
			System.assertNotEquals(false, tSurveyCrm[0].Id!=null, 'Value of parameter is not matching');
		}
	}
}