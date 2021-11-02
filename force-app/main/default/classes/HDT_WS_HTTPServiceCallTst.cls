@isTest
public with sharing class HDT_WS_HTTPServiceCallTst {

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();


    @TestSetup
	static void setup()
    {
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('ArrichDataEntity', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceCredential ('endUser', 'test123', 'usernameTest');
    }

    @isTest
	static void testsendRequest(){

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String nomeApi = 'ArrichDataEntity';

        HDT_WS_ArrichmentDataEntityRequest req = new HDT_WS_ArrichmentDataEntityRequest('IT019283999499','');

        HDT_WS_Response resp = HDT_WS_HTTPServiceCall.sendRequest(nomeApi,req,HDT_WS_ArrichmentDataEntityResponse.class);
        
        system.assertEquals(200, resp.statusCode,'status code is not 200');
        system.assertNotEquals(500, resp.statusCode,'status code is not 500');

        Test.stopTest();
    }

    @isTest
	static void testsendRequest2(){

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        
        String nomeApi = 'ArrichDataEntity';

        List<HDT_WS_Request> reqList = new List<HDT_WS_Request>();

        HDT_WS_Response resp = HDT_WS_HTTPServiceCall.sendRequest(nomeApi,reqList,HDT_WS_ArrichmentDataEntityResponse.class);

        Test.stopTest();

        system.assertEquals(200, resp.statusCode,'status code is not 200');
        system.assertNotEquals(500, resp.statusCode,'status code is not 500');

    }

    @isTest
	static void testsendRequest3(){

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String nomeApi = 'ArrichDataEntity';

        Map<String,String> reqMap = new Map<String,String>();

        HDT_WS_Response resp = HDT_WS_HTTPServiceCall.sendRequest(nomeApi,reqMap,HDT_WS_ArrichmentDataEntityResponse.class);
        Test.stopTest();

        system.assertEquals(200, resp.statusCode,'status code is not 200');
        system.assertNotEquals(500, resp.statusCode,'status code is not 500');
    }

    @isTest
    static void testsendRequest4(){

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String nomeApi = 'ArrichDataEntity';

        Map<String,Object> reqMap = new Map<String,Object>();

        HDT_WS_Response resp = HDT_WS_HTTPServiceCall.sendRequest(nomeApi,reqMap,HDT_WS_ArrichmentDataEntityResponse.class);

        Test.stopTest();

        system.assertEquals(200, resp.statusCode,'status code is not 200');
        system.assertNotEquals(500, resp.statusCode,'status code is not 500');

    }

}
