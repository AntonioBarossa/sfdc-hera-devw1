@istest
public class HDT_BA_CalloutBatchMck implements HttpCalloutMock{ 
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"statusCode": "0", "status": "OK", "errorDetails":"", "body":""}');
        //response.status('Success');
        response.setStatusCode(200);
        return response; 
    }
    
}