/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 20/09/2021
 * @description HDT_LC_ServicePointCustomSettings Test Classes
 * @history Fabricio Petkevicius Nunes – 20/09/2021 – Created class
 */
@isTest
public with sharing class HDT_LC_ServicePointCustomSettingsTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			HDT_UTL_DataFactoryTst.createSelezioneFornitura(1, true);
		}
	}

	@isTest
	public static void testGetCustomSettings(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			CS_SelezioneFornitura__c tCsSelFornitura=HDT_LC_ServicePointCustomSettings.getCustomSettings();

			test.stopTest();

			System.assertEquals('selezioneTestName', tCsSelFornitura.Name, 'CS_SelezioneFornitura__c not returned');
			System.assertNotEquals('', tCsSelFornitura.Name, 'getCustomSettings did not work correctly');
		}
	}
}