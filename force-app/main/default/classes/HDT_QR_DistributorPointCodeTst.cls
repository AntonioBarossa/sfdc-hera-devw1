/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 15/09/2021
 * @description HDT_QR_DistributorPointCode Test Classes
 * @history Fabricio Petkevicius Nunes – 15/09/2021 – Created class
 */
@isTest
public with sharing class HDT_QR_DistributorPointCodeTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_QR_DistributorPointCode distPointCodeQr=new HDT_QR_DistributorPointCode();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		System.runAs(internalUser){

			List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<DistributorPointCode__c> distPointCodes=HDT_UTL_DataFactoryTst.createDistributorPointCode(2, false, accList[0].Id);
			distPointCodes[0].PointCode__c='testPointCode';
			distPointCodes[0].Commodity__c='testCommodity';
			distPointCodes[0].City__c='testComune';

			distPointCodes[1].PointCode__c='testPointCode';
			distPointCodes[1].Commodity__c='Acqua';
			distPointCodes[1].City__c='testComune';

			insert distPointCodes;
		}
	}

	@isTest
	public static void testGetDistributorPointCode(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<DistributorPointCode__c> getDistPointCode=distPointCodeQr.getDistributorPointCode('testPointCode', 'testCommodity', 'testComune', 'Si');

			test.stopTest();

			System.assertEquals(true, getDistPointCode[0].Id!=null, 'Distributor Code not found');
			System.assertNotEquals(false, getDistPointCode[0].Id!=null, 'value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetDistributorPointCode2(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			HDT_QR_DistributorPointCode distQr=new HDT_QR_DistributorPointCode();
			List<DistributorPointCode__c> getDistPointCode=distQr.getDistributorPointCode('testPointCode', 'Acqua', 'testComune', 'Si');

			test.stopTest();

			System.assertEquals(true, getDistPointCode[0].Id!=null, 'Distributor Code not found');
			System.assertNotEquals(false, getDistPointCode[0].Id!=null, 'value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetDistributorPointCode3(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<DistributorPointCode__c> getDistPointCode=distPointCodeQr.getDistributorPointCode('testPointCode', 'testCommodity', 'testComune', 'No');

			test.stopTest();

			System.assertEquals(true, getDistPointCode[0].Id!=null, 'Distributor Code not found');
			System.assertNotEquals(false, getDistPointCode[0].Id!=null, 'value of parameter is not matching');
		}
	}
}