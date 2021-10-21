@isTest
global class HDT_LC_ComunicationsSearchListTstMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": {}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }
}