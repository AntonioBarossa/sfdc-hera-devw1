@isTest
global class HDT_WS_DocumentalIntegrationTstMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String endpoint = request.getEndpoint();
        if(endpoint.endsWithIgnoreCase('Engage1')){
            return responseEngage(request);
        }else if(endpoint.endsWithIgnoreCase('GetAttachmentPostel')){
             return responsePostel(request);
        }else if(endpoint.endsWithIgnoreCase('GetEnvelopePostel')){
            return responsePostel(request);
        }else{
            return responseIntesa(request);
        }
    }
    public static HttpResponse responseEngage(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        String body = request.getBody();
        HDT_WRP_DocumentalRequest requestWrp = (HDT_WRP_DocumentalRequest) JSON.deserialize(body, HDT_WRP_DocumentalRequest.class);
        String requestId = requestWrp.deliverPackageRequest.requestId;
        String responseStr = '{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": {"deliverPackageResponse":{"serviceList":[{"attachmentList":[{"signature":"0","mandatory":"0","version":"21_09","type":"ATT","code":"MOD_H40"},{"signature":"0","mandatory":"0","version":"21_09","type":"ATT","code":"MOD_I40"},{"signature":"0","mandatory":"0","version":"21_09","type":"ATT","code":"MOD_ALL_TEC"}],"serviceId":"'+requestId+'"}],"message":"Composizione eseguita con successo. Totale pagine: 8","result":"000","archive":null,"packageIds":"Aa71teQHAl","requestId":"'+requestId+'","composedDocument":"JVBERi0xLjcKJeLjz9MKNSAwIG9iago"}}}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseStr);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }

    public static HttpResponse responsePostel(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": {"content":"base64"}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }

    public static HttpResponse responseIntesa(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": []}');
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
}