/**​
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
* @date 17/03/2021
* @description HDT_WS_MrrRequest – Rest API for inbound requests in the Mrr JSON format
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/

@RestResource(urlMapping='/MRRInboundService/*')
global with sharing class HDT_WS_MrrRequest {

    private Static HDT_SRV_SalesHandler salesHandlerSrv = new HDT_SRV_SalesHandler();

    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 17/03/2021
    * @description HDT_WS_MrrRequest.doPost() – Manages the POST Method requests
    * @return Descrizione di quanto ritorna il metodo​
    */

    @HttpPost
    webservice static void doPost() {

        // JSONGenerator responseGen = JSON.createGenerator(true);
        // responseGen.writeStartObject();

        HDT_WRP_MrrResponse response = new HDT_WRP_MrrResponse();        
        response.responses = new List<HDT_WRP_MrrResponse.HDT_WRP_Response>();
        
        HDT_WRP_MrrResponse.HDT_WRP_Response mrrResponseItem;
        
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObject = new HDT_WRP_MrrResponse.HDT_WRP_Object();

        HDT_WRP_MrrResponse.HDT_WRP_Field responseField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
        HDT_WRP_MrrResponse.HDT_WRP_Field responseFieldError = new HDT_WRP_MrrResponse.HDT_WRP_Field();

        //INIZIO SVILUPPI EVERIS
        
        HDT_SRV_HerokuPostSalesManager hpsmSrv = new HDT_SRV_HerokuPostSalesManager();
        HDT_WRP_MrrRequest.HDT_WRP_Request postSalesRequest = new HDT_WRP_MrrRequest.HDT_WRP_Request();
        String result;

        //FINE SVILUPPI EVERIS

        try {

            String body = RestContext.request.requestBody.toString();

            HDT_WRP_MrrRequest requestBody = (HDT_WRP_MrrRequest) JSON.deserialize(body, HDT_WRP_MrrRequest.class);

            for (HDT_WRP_MrrRequest.HDT_WRP_Request request : requestBody.requests) {

                mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
                
                HDT_WRP_MrrRequest.HDT_WRP_Header header = request.header;

                mrrResponseItem = (HDT_WRP_MrrResponse.HDT_WRP_Response) JSON.deserialize(JSON.serialize(request), HDT_WRP_MrrResponse.HDT_WRP_Response.class);
                
                mrrResponseItem.objects.clear();

                if(header.fields.get(0).value == 'postsales'){

                    //INIZIO SVILUPPI EVERIS

                    postSalesRequest = request;

                    responseField.fieldType = 'TEXT';
                    responseField.name = 'ESITO';
                    responseField.value = 'OK';

                    responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField};
                    mrrResponseItem.objects.add(responseObject);
                    
                    RestContext.response.statusCode = 200;

                    //FINE SVILUPPI EVERIS

                } else if (header.fields.get(0).value == 'sales') {

                    mrrResponseItem = salesHandlerSrv.manageSalesProcessCategory(request, mrrResponseItem);
                    
                }

            }
            
        } catch (JSONException jsonEx) {

            System.debug('requestbody: ' + String.valueOf(RestContext.request.requestBody));
            System.debug('errorMessage: ' + jsonEx.getMessage());
            System.debug('errorStack: ' + jsonEx.getStackTraceString());
            
            mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();

            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';

            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'Malformed JSON body';

            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>{responseObject};

            RestContext.response.statusCode = 400;

        } catch(Exception e) {
            
            System.debug('requestbody: ' + String.valueOf(RestContext.request.requestBody));
            System.debug('errorMessage: ' + e.getMessage());
            System.debug('errorStack: ' + e.getStackTraceString());

            mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();

            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';

            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'There was an unexpected error';

            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>{responseObject};

            RestContext.response.statusCode = 500;
            
        }

        //INIZIO SVILUPPI EVERIS
        result = hpsmSrv.handleInboundRequest(postSalesRequest);
        //FINE SVILUPPI EVERIS

        // responseGen.writeEndObject();

        // RestContext.response.responseBody = Blob.valueOf(responseGen.getAsString());

        response.responses.add(mrrResponseItem);
        
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        RestContext.response.headers.put('Content-Type', 'application/json');

    }

}