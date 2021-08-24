@isTest
global class HDT_WS_PostSalesTstMock implements HTTPCalloutMock{
    global HTTPResponse  respond(HTTPRequest request){
        String endpoint = request.getEndpoint();
        System.debug(endpoint);
        //Arricchimento Dati
        if(endpoint.equalsIgnoreCase('ArricchimentoDatiTemp')){
            return creaEnrichResposne(request);
        //Pagamenti
        }else if(endpoint.containsIgnoreCase('HDT_')){
            return creaPaymentsResponse(request);
        }else{
            return creaRicResponse(request);
        }
    }
    public static HttpResponse creaRicResponse(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        String recordId = '';
        String body = request.getBody();
        List<HDT_WRP_MrrRequest.HDT_WRP_Request> mrrRequest = (List<HDT_WRP_MrrRequest.HDT_WRP_Request>) JSON.deserialize(body, List<HDT_WRP_MrrRequest.HDT_WRP_Request>.class);
        for(HDT_WRP_MrrRequest.HDT_WRP_Field field : mrrRequest[0].objects[0].fields){
            if(field.name == 'RECORD_ID'){
                recordId = field.value;
            }
        }
        String responseStr = '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
            +'{"fieldType":"TEXT","name":"requestId","value":""},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
            +'{"fieldType":"TEXT","name":"rifRich","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value":'+ recordId +'},'
            +'{"fieldType":"TEXT","name":"FASE","value":"Comunicazione verso Heroku OK"},'
            +'{"fieldType":"TEXT","name":"comunicationChannel","value":null}],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseStr);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }

    public static HttpResponse creaEnrichResposne(HttpRequest request){
        HttpResponse response = new HttpResponse();
        String body = request.getBody();
        String bodyResponse = '{"status": "success","correlationId": "2a0c1340-f6b5-11eb-bb88-068530f44c42","timestamp": "2021-08-06T14:52:33",'
        +'"data": {"testata": {"esito": "OK"},"posizioni": ['
        +'{"campo": "DATACESSAZIONE","valore": "99991231"},'
        +'{"campo": "ALIQUOTAIVA","valore": "01"},'
        +'{"campo": "CA","valore": "200008867681"},'
        +'{"campo": "DESCRFATTURAZCOLL","valore": "Il contratto può essere fatturato con altri contratti"},'
        +'{"campo": "ANNOFABBRCONT","valore": "2000"},'
        +'{"campo": "CALIBRO1","valore": "GRT003"},'
        +'{"campo": "PRESENZACORRETTORE","valore": "NO"},'
        +'{"campo": "OPZIONE","valore": "E_UD_TDR"},'
        +'{"campo": "MOTIVOBLOCCOCALCOLO","valore": "T1"},'
        +'{"campo": "ACCISE","valore": "0.02270000"},'
        +'{"campo": "CODICE_ATECO","valore": "999999"}'
        +']}}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }

    public static HttpResponse creaPaymentsResponse(HttpRequest request){
        HttpResponse response = new HttpResponse();
        String body = request.getBody();
        //successResponse
        String bodyResponse = '{"status": "success","correlationId": "75d76430-04b3-11ec-98ba-022486a4808c","timestamp": "2021-08-24T10:15:38",'
        +'"data": [{"rdsRdo": "","tipoAttivita": "Pratica avviata","note": "","numeroBollettino": "0981023981490","importoTotale": "","esito": "OK"}]}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }
    
}
