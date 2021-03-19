@RestResource(urlMapping='/MRRInboundService/*')
global with sharing class HDT_WS_MrrRequest {
    
    @HttpPost
    webservice static void doPost() {

        JSONGenerator responseGen = JSON.createGenerator(true);
        responseGen.writeStartObject();

        try{ 

            String body = RestContext.request.requestBody.toString();

            HDT_WRP_MrrRequest requestBody = (HDT_WRP_MrrRequest) JSON.deserialize(body, HDT_WRP_MrrRequest.class);

            for (HDT_WRP_MrrRequest.HDT_WRP_Request request : requestBody.requests) {
                
                HDT_WRP_MrrRequest.HDT_WRP_Header header = request.header;

                switch on header.requestType {
                    when 'NOTIF_ES'{

                        if (request.objects.get(0).fields.get(0).name == 'SALESFORCE_KEY') {

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

        } catch(Exception e) {
            
            // responseGen.writeStringField('requestbody', RestContext.request.requestBody.toString());
            // responseGen.writeStringField('RestContext', String.valueOf(RestContext.request));
            // responseGen.writeStringField('errorMessage', e.getMessage());
            // responseGen.writeStringField('errorStack', e.getStackTraceString());

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

        // return responseGen.getAsString();

    }

}