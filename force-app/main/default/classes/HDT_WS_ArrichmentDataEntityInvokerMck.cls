@istest
global class HDT_WS_ArrichmentDataEntityInvokerMck implements HttpCalloutMock{ 
    global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody('{"status":"status","correlationId":"correlationId","timestamp":"timestamp"}');
    response.setStatusCode(200);
    return response; 
}
    
}