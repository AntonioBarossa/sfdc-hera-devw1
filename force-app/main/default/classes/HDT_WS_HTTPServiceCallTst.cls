@isTest
public with sharing class HDT_WS_HTTPServiceCallTst {

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();


    @TestSetup
	static void setup()
    {

		Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);

		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

		List<PermissionSetAssignment> permissionSetAssignments=new List<PermissionSetAssignment>{HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_ADMIN_NAME, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_VOLTURARETROATTIVA, false), HDT_UTL_DataFactoryTst.assignPermissionSet(internalUser, utlConstants.PERMISSIONSET_HDT_SALESFORCE_CPQ_LICENSE_NAME, false)};

		insert permissionSetAssignments;

		System.runAs(internalUser){
            List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');

            insert accList;
           
        }
    }

    @isTest
	static void testsendRequest(){
        Test.startTest();
        String nomeApi = 'ArrichData.Entity';

        HDT_WS_ArrichmentDataEntityRequest req = new HDT_WS_ArrichmentDataEntityRequest('IT019283999499','');

        
        HDT_WS_Response resp = HDT_WS_HTTPServiceCall.sendRequest(nomeApi,req,HDT_WS_ArrichmentDataEntityResponse.class);
	
        Test.stopTest();
        system.assertEquals(200, resp.statusCode,'status code is not 200');
        system.assertNotEquals(500, resp.statusCode,'status code is not 500');
    }

    @isTest
	static void testsendRequest2(){
        Test.startTest();
        
        String nomeApi = 'ArrichData.Entity';

        List<HDT_WS_Request> reqList = new List<HDT_WS_Request>();

        HDT_WS_Response resp = HDT_WS_HTTPServiceCall.sendRequest(nomeApi,reqList,HDT_WS_ArrichmentDataEntityResponse.class);

        Test.stopTest();
        system.assertEquals(200, resp.statusCode,'status code is not 200');
        system.assertNotEquals(500, resp.statusCode,'status code is not 500');
    }

    @isTest
	static void testsendRequest3(){
        Test.startTest();
        String nomeApi = 'ArrichData.Entity';

        Map<String,String> reqMap = new Map<String,String>();

        HDT_WS_Response resp = HDT_WS_HTTPServiceCall.sendRequest(nomeApi,reqMap,HDT_WS_ArrichmentDataEntityResponse.class);
        Test.stopTest();
        system.assertEquals(200, resp.statusCode,'status code is not 200');
        system.assertNotEquals(500, resp.statusCode,'status code is not 500');
    }

}
