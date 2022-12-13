/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 14/09/2021
 * @description Test Class for HDT_QR_RateCategory.cls
 * @history Fabricio Petkevicius Nunes – 14/09/2021 – Created class
 */
@isTest
public class HDT_QR_RateCategoryTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){
			List<RateCategory__c> rates = HDT_UTL_DataFactoryTst.createRateCategoty(2, false);
			rates[1].Market__c = 'Regolamentato';
			insert rates;
		}
	}

	@isTest
	public static void testGetRateList(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<RateCategory__c> tRateCat=HDT_QR_RateCategory.getRateList('testCommodity', 'testDistCode', 'testProduct', 'testFornitura');
			List<RateCategory__c> tRateCatAll=HDT_QR_RateCategory.getAllRecords();
			List<RateCategory__c> tRateCatMarket = HDT_QR_RateCategory.getRecordByMarket('Regolamentato');

			test.stopTest();

			System.assertEquals(true, tRateCat[0].Id!=null, 'RateCategory not found');
			System.assertEquals(true, tRateCatAll[0].Id!=null, 'RateCategoryAll not found');
			System.assertEquals(true, tRateCatMarket[0].Id!=null, 'RateCategoryMarket not found');
		}
	}
}