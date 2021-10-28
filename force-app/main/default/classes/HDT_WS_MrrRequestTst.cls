/**​
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
* @date 18/03/2021
* @description HDT_WS_MrrRequestTst – Test class for the Rest API
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/

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
        //OLD STATUS
        //System.assertEquals(200, RestContext.response.statusCode, 'Rest API requestType NOTIF_ES failed');

        //** [START MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
        System.assertEquals(500, RestContext.response.statusCode, 'Rest API requestType NOTIF_ES failed');
        //** [END MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
    }

    @isTest
    private static Void postWSLead_Callback() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"header":null,"requests":[{"header":{"requestId":"A00000001222","requestTimestamp":null,"requestType":"WSLead_Callback","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"postsales"}]},"objects":[{"fields":[{"fieldType":"TEXT","name":"COD_PRAT_UTENTE","value":"A00000001222"},{"fieldType":"TEXT","name":"RECORD_ID","value":"5003N000008q5AAQAY"},{"fieldType":"TEXT","name":"ATTIVITA","value":"WRONG"},{"fieldType":"TEXT","name":"METHOD","value":"esito_intermedio"},{"fieldType":"TEXT","name":"UTENZA","value":"utente_hera"},{"fieldType":"TEXT","name":"DATA_EVENTO","value":"2021-06-22 12:44:31"}],"id":null,"name":null,"objectType":null,"objects":null}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(200, RestContext.response.statusCode, 'Rest API requestType WSLead_Callback failed');
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
        
        //OLD STATUS
        //System.assertEquals(400, RestContext.response.statusCode, 'Rest API requestType NOTIF_ES should fail');
        //** [START MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
        System.assertEquals(500, RestContext.response.statusCode, 'Rest API requestType NOTIF_ES should fail');
        //** [END MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status

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
        
        //OLD STATUS
        //System.assertEquals(200, RestContext.response.statusCode, 'Rest API requestType RICH_PASS failed');

        //** [START MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
        System.assertEquals(500, RestContext.response.statusCode, 'Rest API requestType RICH_PASS failed');
        //** [END MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
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
        
        //OLD STATUS
        //System.assertEquals(400, RestContext.response.statusCode, 'Rest API requestType RICH_PASS should fail');

        //** [START MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
        //System.assertEquals(200, RestContext.response.statusCode, 'Rest API requestType RICH_PASS should fail');
        //** [END MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
        System.assertEquals(500, RestContext.response.statusCode, 'Rest API requestType RICH_PASS should fail');
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
        
        //OLD STATUS
        //System.assertEquals(400, RestContext.response.statusCode, 'Unsupporter requestType should fail');
        //** [START MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
        System.assertEquals(500, RestContext.response.statusCode, 'Unsupporter requestType should fail');
        //** [END MOD 2021-08-03] @Author:Luca Belometti WR (luca.belometti@webresults.it) @Description: Changed Status
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

    @isTest
    private static Void postJSONException() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"requests": ["header": {"requestId": "","requestTimestamp": "","requestType": "WRONG"},"objects": [{"fields": [{"fieldType": "","name": "","value": ""}],"id": "","name": "","objects": [],"objectType": "Case"}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(400, RestContext.response.statusCode, 'Apex JSON error, should fail');
    }
    
    @isTest
    private static Void postCustomException() {
              
		List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'HERA COMM','Azienda','Aziende SME');
        
        List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(1, true, accs[0].id, 'Bozza');
        
        Id myOrder = [Select id From Order][0].id;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/MRRInboundService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"header":null,"requests":[{"header":{"requestId":"A00000001222","requestTimestamp":null,"requestType":"NOTIF_ES","fields":[{"fieldType":"TEXT","name":"PROCESS_CATEGORY","value":"sales"}]},"objects":[{"fields":[{"fieldType":"TEXT","name":"COD_PRAT_UTENTE","value":"A00000001222"},{"fieldType":"TEXT","name":"RECORD_ID","value":"'+myOrder+'"},{"fieldType":"TEXT","name":"FASE","value":"Completata"},{"fieldType":"TEXT","name":"ATTIVITA","value":"WRONG"},{"fieldType":"TEXT","name":"METHOD","value":"esito_intermedio"},{"fieldType":"TEXT","name":"UTENZA","value":"utente_hera"},{"fieldType":"TEXT","name":"DATA_EVENTO","value":"2021-06-22 12:44:31"}],"id":null,"name":null,"objectType":null,"objects":[{"fields":[{"fieldType":"TEXT","name":"DATA_EVENTO","value":"2021-06-22 12:44:31"}]}]}]}]}');

        RestContext.request = req;
        RestContext.response = res;
        
        HDT_WS_MrrRequest.doPost();

        System.debug(RestContext.response.responseBody.toString());
        
        System.assertEquals(500, RestContext.response.statusCode, 'should fail throwing a Custom Exception');
    }

}