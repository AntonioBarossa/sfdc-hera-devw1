/**​
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
* @date 17/03/2021
* @description HDT_WS_MrrRequest – Rest API for inbound requests in the Mrr JSON format
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/

@RestResource(urlMapping='/MRRInboundService/*')
global with sharing class HDT_WS_MrrRequest {
    /**​
    * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
    * @date 17/03/2021
    * @description HDT_WS_MrrRequest.doPost() – Manages the POST Method requests
    * @return Descrizione di quanto ritorna il metodo​
    */

    @HttpPost
    webservice static void doPost() {

        JSONGenerator responseGen = JSON.createGenerator(true);
        responseGen.writeStartObject();

        //INIZIO SVILUPPI EVERIS
        
        HDT_UTL_PostSalesManager psmUtl = new HDT_UTL_PostSalesManager();

        //FINE SVILUPPI EVERIS

        try {

            String body = RestContext.request.requestBody.toString();

            HDT_WRP_MrrRequest requestBody = (HDT_WRP_MrrRequest) JSON.deserialize(body, HDT_WRP_MrrRequest.class);

            for (HDT_WRP_MrrRequest.HDT_WRP_Request request : requestBody.requests) {
                
                HDT_WRP_MrrRequest.HDT_WRP_Header header = request.header;

                switch on header.requestType {
                    when 'NOTIF_ES'{

                        //INIZIO SVILUPPI EVERIS

                        if(header.fields.get(0).value == 'postsales'){

                            psmUtl.handleInboundRequest(request);

                            responseGen.writeStringField('status', 'success');
                            
                            RestContext.response.statusCode = 200;

                        } 

                        //FINE SVILUPPI EVERIS

                        else if (request.objects.get(0).fields.get(0).name == 'SALESFORCE_KEY') {

                            responseGen.writeStringField('status', 'success');
                            
                            RestContext.response.statusCode = 200;
                            
                        } else {

                            responseGen.writeStringField('status', 'failed');
                        
                            responseGen.writeFieldName('errorDetails');
                            responseGen.writeStartArray();
                                responseGen.writeStartObject();
                                    responseGen.writeStringField('code', 'BAD_REQUEST');
                                    responseGen.writeStringField('message', 'There was an issue with your request message');
                                responseGen.writeEndObject();
                            responseGen.writeEndArray();
                            RestContext.response.statusCode = 400;

                        }                        

                    }
                    when 'RICH_PASS' {


                        if (request.objects.get(0).fields.get(0).name == 'CODICE_CONTRATTO'){

                            responseGen.writeStringField('rdo', '');
                            responseGen.writeStringField('rds', '');
                            responseGen.writeStringField('status', 'success');
                            
                            RestContext.response.statusCode = 200;
                            
                        } else {

                            responseGen.writeStringField('rdo', '');
                            responseGen.writeStringField('rds', '');
                            responseGen.writeStringField('status', 'failed');

                            responseGen.writeFieldName('errorDetails');
                            responseGen.writeStartArray();
                                responseGen.writeStartObject();
                                    responseGen.writeStringField('code', 'BAD_REQUEST');
                                    responseGen.writeStringField('message', 'There was an issue with your request message');
                                responseGen.writeEndObject();
                            responseGen.writeEndArray();
                            RestContext.response.statusCode = 400;

                        }

                    }
                    when else {

                        responseGen.writeStringField('status', 'failed');

                        responseGen.writeFieldName('errorDetails');
                        responseGen.writeStartArray();
                            responseGen.writeStartObject();
                                responseGen.writeStringField('code', 'BAD_REQUEST');
                                responseGen.writeStringField('message', 'Unsupported requestType');
                            responseGen.writeEndObject();
                        responseGen.writeEndArray();
                        RestContext.response.statusCode = 400;

                    }
                }

            }
            
        } catch (JSONException jsonEx) {

            System.debug('requestbody: ' + String.valueOf(RestContext.request.requestBody));
            System.debug('errorMessage: ' + jsonEx.getMessage());
            System.debug('errorStack: ' + jsonEx.getStackTraceString());
            
            responseGen.writeStringField('status', 'failed');

            responseGen.writeFieldName('errorDetails');
            responseGen.writeStartArray();
                responseGen.writeStartObject();
                    responseGen.writeStringField('code', 'BAD_REQUEST');
                    responseGen.writeStringField('message', 'Malformed JSON body');
                responseGen.writeEndObject();
            responseGen.writeEndArray();

            RestContext.response.statusCode = 400;

        } catch(Exception e) {
            
            System.debug('requestbody: ' + String.valueOf(RestContext.request.requestBody));
            System.debug('errorMessage: ' + e.getMessage());
            System.debug('errorStack: ' + e.getStackTraceString());

            responseGen.writeStringField('status', 'failed');

            responseGen.writeFieldName('errorDetails');
            responseGen.writeStartArray();
                responseGen.writeStartObject();
                    responseGen.writeStringField('code', 'APEX_ERROR');
                    responseGen.writeStringField('message', 'There was an unexpected error');
                responseGen.writeEndObject();
            responseGen.writeEndArray();

            RestContext.response.statusCode = 500;
            
        }

        responseGen.writeEndObject();

        RestContext.response.responseBody = Blob.valueOf(responseGen.getAsString());
        RestContext.response.headers.put('Content-Type', 'application/json');

    }

}