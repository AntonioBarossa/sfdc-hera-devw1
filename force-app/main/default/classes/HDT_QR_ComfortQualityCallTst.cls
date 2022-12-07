/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 16/09/2021
 * @description HDT_QR_ComfortQualityCall Test Classes
 * @history Fabricio Petkevicius Nunes – 16/09/2021 – Created class
 */
@isTest
public with sharing class HDT_QR_ComfortQualityCallTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	private static HDT_QR_DistributorPointCode distPointCodeQr=new HDT_QR_DistributorPointCode();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
			List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
			orders[0].Channel__c='testChannel';
			orders[0].CustomerCategory__c='Aziende';
			orders[0].MarketOrigin__c='Default';
			orders[0].Market__c = 'Libero';
			orders[0].RecordTypeId = constants.ORDER_RECORDTYPEID_VAS;
			insert orders;

			List<ComfortQualityCall__c> comfQualCallList=HDT_UTL_DataFactoryTst.createComfortQualityCall(1, false);
			comfQualCallList[0].Process__c='HDT_RT_Vas';
			comfQualCallList[0].Channel__c=orders[0].Channel__c;
			comfQualCallList[0].CustomerType__c=orders[0].CustomerCategory__c;
			comfQualCallList[0].MarketType__c=orders[0].Market__c;
			comfQualCallList[0].ComfortSignatureMethod__c=orders[0].SignatureMethod__c;
			comfQualCallList[0].DocumentValidation__c=true;
			comfQualCallList[0].ComfortEnabled__c=true;

			insert comfQualCallList;
		}
	}

	@isTest
	public static void testGetRecordByOrderParams(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Order> tOrder=[SELECT Id, Channel__c, RecordType.DeveloperName, CustomerCategory__c,Market__c, MarketOrigin__c, SignatureMethod__c
			                    FROM Order
			                    WHERE Channel__c='testChannel'];

			List<ComfortQualityCall__c> getRecByOrderParams=HDT_QR_ComfortQualityCall.getRecordByOrderParams(tOrder[0]);

			test.stopTest();

			System.assertEquals(true, getRecByOrderParams[0].Id!=null, 'ComfortQualityCall not found');
			System.assertNotEquals(false, getRecByOrderParams[0].Id!=null, 'value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetRecordByOrderParamsVas(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<Order> tOrder=[SELECT Id, Channel__c, RecordType.DeveloperName,Market__c, CustomerCategory__c, MarketOrigin__c, SignatureMethod__c, DocSendingMethod__c
			                    FROM Order
			                    WHERE Channel__c='testChannel'];

			List<ComfortQualityCall__c> getRecByOrderParamVas=HDT_QR_ComfortQualityCall.getRecordByOrderParamsVas(tOrder[0]);

			test.stopTest();

			System.assertEquals(true, getRecByOrderParamVas[0].Id!=null, 'ComfortQualityCall not found');
			System.assertNotEquals(false, getRecByOrderParamVas[0].Id!=null, 'value of parameter is not matching');
		}
	}

	@isTest
	public static void testGetRecordsWithDocumentValidation(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<ComfortQualityCall__c> getRecWithDocValidation=HDT_QR_ComfortQualityCall.getRecordsWithDocumentValidation('Posta Cartacea');

			test.stopTest();

			System.assertEquals(true, getRecWithDocValidation[0].Id!=null, 'ComfortQualityCall not found');
			System.assertNotEquals(false, getRecWithDocValidation[0].Id!=null, 'value of parameter is not matching');
		}
	}
}