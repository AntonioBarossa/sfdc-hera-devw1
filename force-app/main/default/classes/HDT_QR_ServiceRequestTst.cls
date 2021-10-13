/**
 * @author Fabricio Petkevicius Nunes (fabricio.nunes@engdb.com.br)
 * @date 15/09/2021
 * @description Test Class for HDT_QR_ServiceRequest.cls
 * @history Fabricio Petkevicius Nunes – 15/09/2021 – Created class
 */
@isTest
public class HDT_QR_ServiceRequestTst{
	private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
	static void makeData(){
		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, true);

		System.runAs(internalUser){

			List<ServiceRequest__c> servReqs=HDT_UTL_DataFactoryTst.createServiceRequest(1, false);
			servReqs[0].Status__c='Bozza';
			insert servReqs;
		}
	}

	@isTest
	public static void testGetServiceRequestByOrderCaseIds(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<ServiceRequest__c> tServReq=[SELECT Id, ProcessType__c, Status__c
			                                  FROM ServiceRequest__c
			                                  WHERE ProcessType__c='Alert'];

			Set<Id> servReqIds=new Set<Id>();
			servReqIds.add(tServReq[0].Id);

			List<ServiceRequest__c> servReqByOrderCaseId=HDT_QR_ServiceRequest.getServiceRequestByOrderCaseIds(servReqIds, 'Id');

			System.debug('servReqByOrderCaseId = '+servReqByOrderCaseId);

			test.stopTest();

			System.assertEquals(true, servReqByOrderCaseId[0].Id!=null, 'Service Request not found');
			System.assertNotEquals(false, servReqByOrderCaseId[0].Id!=null, 'Value of parameter is not matching');
		}
	}
}