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

			List<ServiceRequest__c> servReqs=HDT_UTL_DataFactoryTst.createServiceRequest(2, false);
			servReqs[0].Status__c='Bozza';
            servReqs[0].type__c='Case';
            servReqs[0].Case__c = null;
            servReqs[1].Status__c='Annullato';
			insert servReqs;
		}
	}

	@isTest
	public static void testGetServiceRequestsSameServicePoint(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<ServiceRequest__c> tServReq=[SELECT Id, ProcessType__c, Status__c, ServicePointCode__c
			                                  FROM ServiceRequest__c
			                                  WHERE ProcessType__c='Alert'];


			List<ServiceRequest__c> servReqByOrderCaseId=HDT_QR_ServiceRequest.getServiceRequestsSameServicePoint(String.valueOf(tServReq[0].ServicePointCode__c), 'Alert');

			System.debug('servReqByOrderCaseId = '+servReqByOrderCaseId);

			test.stopTest();

			System.assertEquals(true, servReqByOrderCaseId[0].Id!=null, 'Service Request not found');
			System.assertNotEquals(false, servReqByOrderCaseId[0].Id!=null, 'Value of parameter is not matching');
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
    
        	@isTest
	public static void testetCanceledServiceRequests(){

		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<ServiceRequest__c> tServReq=[SELECT Id, ProcessType__c, Status__c, ServicePointCode__c
			                                  FROM ServiceRequest__c
			                                  WHERE ProcessType__c='Alert'
                                              AND Status__c='Annullato'];

			Set<Id> servReqIds=new Set<Id>();
			servReqIds.add(tServReq[0].Id);

			List<ServiceRequest__c> servReqByOrderCaseId=HDT_QR_ServiceRequest.getCanceledServiceRequests(String.valueOf(tServReq[0].ServicePointCode__c));

			System.debug('servReqByOrderCaseId = '+servReqByOrderCaseId);

			test.stopTest();

			System.assertEquals(true, servReqByOrderCaseId[0].Id!=null, 'Service Request not found');
			System.assertNotEquals(false, servReqByOrderCaseId[0].Id!=null, 'Value of parameter is not matching');
		}
	}

	@isTest
	public static void getTransitoryServiceRequest(){
		List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
		List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(2, false, accs[0].id, 'Bozza');
		orders[0].isTransition__c = true;
		insert orders[0];
		orders[1].isTransition__c = true;
		orders[1].OrderReference__c = orders[0].Id;
		insert orders[1];

		List<ServiceRequest__c> tServReq=[SELECT Id, ProcessType__c, Status__c, ServicePointCode__c
			                                  FROM ServiceRequest__c];
	
		tServReq[0].type__c = 'Order';
		tServReq[0].Order__c = orders[0].Id;
		tServReq[1].type__c = 'Order';
		tServReq[1].Order__c = orders[1].Id;
		update tServReq;
		User tUser=[SELECT Id
		            FROM User
		            WHERE Alias='crmuser'
		            LIMIT 1];

		System.runAs(tUser){

			test.startTest();

			List<ServiceRequest__c> transitoryServReq=HDT_QR_ServiceRequest.getTransitoryServiceRequest(new Set<Id> {orders[0].Id}, new Set<Id>(), new Set<Id>());
			System.assertEquals(1, transitoryServReq.size(), 'Service Request not found');
			transitoryServReq=HDT_QR_ServiceRequest.getTransitoryServiceRequest(new Set<Id> {orders[0].Id}, new Set<Id> {orders[0].Id}, new Set<Id> {orders[0].Id});


			test.stopTest();

			System.assertEquals(2, transitoryServReq.size(), 'Service Request not found');
		}
	}
}