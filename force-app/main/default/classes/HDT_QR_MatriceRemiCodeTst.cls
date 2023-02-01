/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 13/09/2021
 * @description HDT_QR_MatriceRemiCode Test Classes
 * @history Fabricio Petkevicius Nunes – 13/09/2021 – Created class
 */
@isTest
public with sharing class HDT_QR_MatriceRemiCodeTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		insert internalUser;

		System.runAs(internalUser){

			List<MatriceRemiCode__c> matriceRemiCodes=HDT_UTL_DataFactoryTst.createMatriceRemiCode(1, false);
			matriceRemiCodes[0].Comune__c='testComune';
            date stDate=date.today();
			matriceRemiCodes[0].startDate__c=stdate.addDays(-5);
            matriceRemiCodes[0].endDate__c=stdate.addDays(5);
			insert matriceRemiCodes;
		}
	}

	@isTest
	public static void testGetAllRecord(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<MatriceRemiCode__c> tMatRemiCodes=HDT_QR_MatriceRemiCode.getAllRecord();

			test.stopTest();

			System.assertEquals(true, tMatRemiCodes[0].Id!=null, 'Matrice Remi Code not found');
			System.assertNotEquals(false, tMatRemiCodes[0].Id!=null, 'value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetAllRemiConfiguration(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<MatriceRemiCode__c> tMatRemiCodes=HDT_QR_MatriceRemiCode.getAllRemiConfiguration();

			test.stopTest();

			System.assertEquals(true, tMatRemiCodes[0].Id!=null, 'Matrice Remi Code not found');
			System.assertNotEquals(false, tMatRemiCodes[0].Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetAllPartitaUdbConfiguration(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<MatriceRemiCode__c> tMatRemiCode=[SELECT Id, RemiCode__c
			                                       FROM MatriceRemiCode__c
			                                       WHERE RemiCode__c='test'];

			tMatRemiCode[0].SalesCompany__c='testSaleCo';

			update tMatRemiCode;

			Set<String> tComuni=new Set<String>();
			tcomuni.add('testComune');

			List<MatriceRemiCode__c> tMatRemiCodes=HDT_QR_MatriceRemiCode.getAllPartitaUdbConfiguration(tComuni);


			test.stopTest();

			System.assertEquals(true, tMatRemiCodes[0].Id!=null, 'Matrice Remi Code not found');
			System.assertNotEquals(false, tMatRemiCodes[0].Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetAllRemiVATNumberUdb(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<MatriceRemiCode__c> tMatRemiCode=[SELECT Id, RemiCode__c
			                                       FROM MatriceRemiCode__c
			                                       WHERE RemiCode__c='test'];

			tMatRemiCode[0].SalesCompany__c='testSaleCo';
			//tMatRemiCode[0].EndDate__c= Date.newInstance(2023, 1, 27);
			//tMatRemiCode[0].StartDate__c=Date.newInstance(2023, 1, 25);

			update tMatRemiCode;

			String comune = 'testComune'; 

			List<MatriceRemiCode__c> tMatRemiCodes=HDT_QR_MatriceRemiCode.getAllRemiVATNumberUdb(tMatRemiCode[0].RemiCode__c , comune, tMatRemiCode[0].SalesCompany__c);
			List<MatriceRemiCode__c> remiCodeList=[SELECT Id, RemiCode__c, Comune__c, SalesCompany__c, VATNumberUdb__c, isActive__c FROM MatriceRemiCode__c];

			test.stopTest();

			System.assertEquals(true, tMatRemiCodes[0].Id!=null, 'Matrice Remi Code not found');
			System.assertNotEquals(false, tMatRemiCodes[0].Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	public static void tesGetAllRemiVATNumberUdbServicePoint(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<MatriceRemiCode__c> tMatRemiCode=[SELECT Id, RemiCode__c
			                                       FROM MatriceRemiCode__c
			                                       WHERE RemiCode__c='test'];

			tMatRemiCode[0].SalesCompany__c='testSaleCo';
			//tMatRemiCode[0].EndDate__c= Date.newInstance(2023, 1, 27);
			//tMatRemiCode[0].StartDate__c=Date.newInstance(2023, 1, 25);

			update tMatRemiCode;

			Set<String> tComuni=new Set<String>();
			Set<String> tCompanies=new Set<String>();

			tcomuni.add('testComune');
			tCompanies.add('testSaleCo');

			List<MatriceRemiCode__c> tMatRemiCodes=HDT_QR_MatriceRemiCode.getAllRemiVATNumberUdbServicePoint(tcomuni, tCompanies);
			List<MatriceRemiCode__c> remiCodeList=[SELECT Id, RemiCode__c, Comune__c, SalesCompany__c, VATNumberUdb__c, isActive__c FROM MatriceRemiCode__c];

			test.stopTest();

			System.assertEquals(true, tMatRemiCodes[0].Id!=null, 'Matrice Remi Code not found');
			System.assertNotEquals(false, tMatRemiCodes[0].Id!=null, 'Value of parameter is not matching');
		}
	}
}