@isTest
global class HDT_WS_PostSalesTstMock implements HTTPCalloutMock{
    global HTTPResponse  respond(HTTPRequest request){
        String endpoint = request.getEndpoint();
        System.debug(endpoint);
        if(endpoint.equalsIgnoreCase('ArricchimentoDatiTemp')){
            return creaEnrichResposne(request);
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
        String bodyResponse = '';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }
    
}
