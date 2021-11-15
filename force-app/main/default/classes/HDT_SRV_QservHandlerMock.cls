public with sharing class HDT_SRV_QservHandlerMock implements HttpCalloutMock {

    HttpResponse res = new HttpResponse();

    public HDT_SRV_QservHandlerMock(HttpResponse response){
        this.res = response;
    }

    public HTTPResponse respond(HTTPRequest req) {
    
        return res;

    }

}
