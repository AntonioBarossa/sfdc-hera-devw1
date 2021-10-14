/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 15/09/2021
 * @description Test Class for HDT_QR_Blacklist.cls
 * @history Fabricio Petkevicius Nunes – 15/09/2021 – Created class
 */
@isTest
public class HDT_QR_BlacklistTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_QR_Blacklist blacklistQr=new HDT_QR_Blacklist();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<BlackList__c> blacklists=HDT_UTL_DataFactoryTst.createBlacklist(1, true);
		}
	}

	@isTest
	public static void testGetAllBlacklist(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<BlackList__c> tGetAllBlacklist=HDT_QR_Blacklist.getAllBlacklist();

			test.stopTest();

			System.assertEquals(true, tGetAllBlacklist[0].Id!=null, 'Blacklists not found');
			System.assertNotEquals(false, tGetAllBlacklist[0].Id!=null,'value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetAllBlacklistEmail(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<BlackList__c> tGetAllBlacklistEmail=HDT_QR_Blacklist.getAllBlacklistEmail();

			test.stopTest();

			System.assertEquals(true, tGetAllBlacklistEmail[0].Id!=null, 'Blacklists not found');
			System.assertNotEquals(false, tGetAllBlacklistEmail[0].Id!=null,'value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetBlacklist(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			BlackList__c tGetBlacklist=blacklistQr.getBlacklist('testPOD');

			test.stopTest();

			System.assertEquals(true, tGetBlacklist.Id!=null, 'Blacklist not found');
			System.assertNotEquals(false, tGetBlacklist.Id!=null,'value of parameter is not matching');
		}
	}
}