@isTest
global  with sharing class HDT_WS_PostSalesTstMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest request){
        String endpoint = request.getEndpoint();
        System.debug(endpoint);
    }
    public static HttpResponse creaRicResponse(HTTPRequest request){

    }
    public static Map<String, Object> createRequestMap(HTTPRequest request){
        
    }
}
