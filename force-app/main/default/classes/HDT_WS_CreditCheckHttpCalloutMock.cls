/**
 * @author Valere (valere@noeli-it.net)
 * @date 29/09/2021
 * @description HDT_WS_CreditCheck Test Class
 * @history valere - 29/09/2021– Created Class
 */
@isTest
public class HDT_WS_CreditCheckHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{ "errorDetails": [{"code": "code", "message": {"key":"value"}, "additionalInfo": "additionalInfo" },'+
                        ' {"code": "code2", "message": {"key":"value"}, "additionalInfo": "additionalInfo2" }] }');
        response.setStatusCode(200);
        return response; 
    }
}