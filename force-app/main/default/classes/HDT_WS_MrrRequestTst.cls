@isTest
public with sharing class HDT_WS_MrrRequestTst {

    @isTest
    private static Void postNotifEs() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"requests": [{"header": {"requestId": "","requestTimestamp": "","requestType": "NOTIF_ES"},"objects": [{"fields": [{"fieldType": "","name": "SALESFORCE_KEY","value": ""}],"id": "","name": "","objects": [],"objectType": "Case"}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(200, RestContext.response.statusCode, 'Rest API requestType NOTIF_ES failed');
    }

    @isTest
    private static Void postNotifEsFail() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"requests": [{"header": {"requestId": "","requestTimestamp": "","requestType": "NOTIF_ES"},"objects": [{"fields": [{"fieldType": "","name": "WRONG","value": ""}],"id": "","name": "","objects": [],"objectType": "Case"}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(400, RestContext.response.statusCode, 'Rest API requestType NOTIF_ES should fail');
    }

    @isTest
    private static Void postRichPass() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"requests": [{"header": {"requestId": "","requestTimestamp": "","requestType": "RICH_PASS"},"objects": [{"fields": [{"fieldType": "","name": "CODICE_CONTRATTO","value": ""}],"id": "","name": "","objects": [],"objectType": "Case"}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(200, RestContext.response.statusCode, 'Rest API requestType RICH_PASS failed');
    }

    @isTest
    private static Void postRichPassFail() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"requests": [{"header": {"requestId": "","requestTimestamp": "","requestType": "RICH_PASS"},"objects": [{"fields": [{"fieldType": "","name": "WRONG","value": ""}],"id": "","name": "","objects": [],"objectType": "Case"}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(400, RestContext.response.statusCode, 'Rest API requestType RICH_PASS should fail');
    }

    @isTest
    private static Void postUnsupportedRequest() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"requests": [{"header": {"requestId": "","requestTimestamp": "","requestType": "WRONG"},"objects": [{"fields": [{"fieldType": "","name": "","value": ""}],"id": "","name": "","objects": [],"objectType": "Case"}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(400, RestContext.response.statusCode, 'Unsupporter requestType should fail');
    }

    @isTest
    private static Void postException() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';        

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(500, RestContext.response.statusCode, 'Apex error, should fail');
    }

}