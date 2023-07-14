/**​
* @author Andrei Necsulescu (andrei.necsulescu@webresults.it)​
* @date 17/03/2021
* @description HDT_WS_MrrRequest – Rest API for inbound requests in the Mrr JSON format
* @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica​
*/
@SuppressWarnings('PMD.AvoidDebugStatements')
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
        //String result;

        //FINE SVILUPPI EVERIS

        try {

            Boolean richiestaNonIdentificata = true;

            String body = RestContext.request.requestBody.toString();

            HDT_WRP_MrrRequest requestBody = (HDT_WRP_MrrRequest) JSON.deserialize(body, HDT_WRP_MrrRequest.class);
            
            HDT_UTL_Scarti.handleMRRInboundRequest(requestBody.requests);//>> 08/10/2021 costanzo.lomele@webresults.it - nuovi sviluppi cb scarti, attività di tracciamento
            Boolean discardManagement = false;
            for (HDT_WRP_MrrRequest.HDT_WRP_Request request : requestBody.requests) {
                mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();
                HDT_WRP_MrrRequest.HDT_WRP_Header header = request.header;
                mrrResponseItem = (HDT_WRP_MrrResponse.HDT_WRP_Response) JSON.deserialize(JSON.serialize(request), HDT_WRP_MrrResponse.HDT_WRP_Response.class);
                mrrResponseItem.objects.clear();
                if (header.fields != null && header.fields.get(0).value == 'sales') {
                    richiestaNonIdentificata = false;
                    mrrResponseItem = salesHandlerSrv.manageSalesProcessCategory(request, mrrResponseItem);
                    discardManagement = true;
                }
            }

            if(requestBody.requests[0].header.fields != null && requestBody.requests[0].header.fields.get(0).value == 'postsales'){
                richiestaNonIdentificata = false;
                HDT_SRV_BillableVasDeactivation.handlerAsyncronousNotify(requestBody.requests[0]);
                //HDT_SRV_BillableVasDeactivation billableVasHndlr = new HDT_SRV_BillableVasDeactivation(requestBody.requests[0]);
                if (requestBody.requests[0].header.requestType=='NOTIF_VAS') {
                    mrrResponseItem = salesHandlerSrv.manageSalesProcessCategory(requestBody.requests[0], mrrResponseItem);
                }//else if(billableVasHndlr.isPostSalesOrder()){
                    //mrrResponseItem = billableVasHndlr.manageBillableVasDeactivation(requestBody.requests[0], mrrResponseItem);
                //}
                else {
                    //INIZIO SVILUPPI EVERIS
                    mrrResponseItem = (HDT_WRP_MrrResponse.HDT_WRP_Response) JSON.deserialize(JSON.serialize(requestBody.requests[0]), HDT_WRP_MrrResponse.HDT_WRP_Response.class);
                    mrrResponseItem.objects.clear();
                    postSalesRequest = requestBody.requests[0];
                    responseObject = hpsmSrv.handleInboundRequest(postSalesRequest);
                    mrrResponseItem.objects.add(responseObject);
                    //FINE SVILUPPI EVERIS
                }
            }else if (requestBody.requests[0].header.fields != null && String.isBlank(requestBody.requests[0].header.fields.get(0).value)){
                throw new HDT_UTL_HeraException('Required Header Field Missing: PROCESS_CATEGORY');
            }
            if (richiestaNonIdentificata && requestBody.requests[0].objects != null && !requestBody.requests[0].objects.isEmpty() 
                && requestBody.requests[0].objects[0] != null && requestBody.requests[0].objects[0].fields != null ){
                    List<HDT_WRP_MrrResponse.HDT_WRP_Field> esitoFields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
                    for (HDT_WRP_MrrRequest.HDT_WRP_Field field : requestBody.requests[0].objects[0].fields){
                        if ('Richiesta non identificata'.equalsIgnoreCase(field.value)){
                            HDT_WRP_MrrResponse.HDT_WRP_Field esitoField = new HDT_WRP_MrrResponse.HDT_WRP_Field();
                            esitoField.fieldType = 'TEXT';
                            esitoField.name = 'ESITO';
                            esitoField.value = 'OK';
                            esitoFields.add(esitoField);
                            break;
                        }
                    }
                    if (!esitoFields.isEmpty()){
                        mrrResponseItem = (HDT_WRP_MrrResponse.HDT_WRP_Response) JSON.deserialize(JSON.serialize(requestBody.requests[0]), HDT_WRP_MrrResponse.HDT_WRP_Response.class);
                        responseObject.fields = esitoFields;
                        mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>{responseObject};
                    }
            }
            //Nel Case crea l'activity anche se l'aggiornamento del case va in errore crea l'activity.  Quindi lo chiamo solo per i processi sales
            // gestisco i postSales nel metodo hpsmSrv.handleInboundRequest(postSalesRequest);
            if (discardManagement){
                HDT_UTL_Scarti.discardManagement(requestBody.requests);
            }
        } catch (JSONException jsonEx) {

            System.debug(LoggingLevel.DEBUG,'requestbody: ' + String.valueOf(RestContext.request.requestBody));
            System.debug(LoggingLevel.DEBUG,'errorMessage: ' + jsonEx.getMessage());
            System.debug(LoggingLevel.DEBUG,'errorStack: ' + jsonEx.getStackTraceString());
            
            mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();

            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';

            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = 'Malformed JSON body';

            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>{responseObject};
            HDT_UTL_IntegrationLog.handleMrrRequest(RestContext.request.requestBody.toString(),jsonEx.getMessage() + ' ' + jsonEx.getStackTraceString());
            RestContext.response.statusCode = 400;

        }catch(CustomMessageException e){

            System.debug(LoggingLevel.DEBUG,'requestbody: ' + String.valueOf(RestContext.request.requestBody));
            System.debug(LoggingLevel.DEBUG,'errorMessage: ' + e.getMessage());
            System.debug(LoggingLevel.DEBUG,'errorStack: ' + e.getStackTraceString());

            mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();

            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';

            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = e.getMessage();

            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>{responseObject};
            HDT_UTL_IntegrationLog.handleMrrRequest(RestContext.request.requestBody.toString(),e.getMessage() + ' ' + e.getStackTraceString());
            RestContext.response.statusCode = 500;

        }catch(Exception e) {
            
            System.debug(LoggingLevel.DEBUG,'requestbody: ' + String.valueOf(RestContext.request.requestBody));
            System.debug(LoggingLevel.DEBUG,'errorMessage: ' + e.getMessage());
            System.debug(LoggingLevel.DEBUG,'errorStack: ' + e.getStackTraceString());

            mrrResponseItem = new HDT_WRP_MrrResponse.HDT_WRP_Response();

            responseField.fieldType = 'TEXT';
            responseField.name = 'ESITO';
            responseField.value = 'KO';

            responseFieldError.fieldType = 'TEXT';
            responseFieldError.name = 'ERROR_MESSAGE';
            responseFieldError.value = e.getMessage();

            responseObject.fields = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>{responseField, responseFieldError};
            mrrResponseItem.objects = new List<HDT_WRP_MrrResponse.HDT_WRP_Object>{responseObject};
            HDT_UTL_IntegrationLog integClass = new HDT_UTL_IntegrationLog();
            HDT_UTL_IntegrationLog.handleMrrRequest(RestContext.request.requestBody.toString(),e.getMessage() + ' ' + e.getStackTraceString());
            RestContext.response.statusCode = 500;
            
        } 

        // responseGen.writeEndObject();

        // RestContext.response.responseBody = Blob.valueOf(responseGen.getAsString());

        response.responses.add(mrrResponseItem);
        
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        RestContext.response.headers.put('Content-Type', 'application/json');

    }


    public virtual class CustomMessageException extends Exception{} //NOPMD

}