@istest
global class HDT_QBL_SIE34_2SMETstMck implements HttpCalloutMock{ 
    global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody('{"statusCode": "0", "status": "Success", "errorDetails":"", "body":""}');
    //response.status('Success');
    response.setStatusCode(200);
    return response; 
}
    
}
