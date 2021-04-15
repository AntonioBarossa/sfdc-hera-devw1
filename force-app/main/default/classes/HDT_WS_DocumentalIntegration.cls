public with sharing class HDT_WS_DocumentalIntegration {
    public static HDT_WRP_DocumentalResponse submitRequest(String body){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('Callout:Engage1');
        req.setMethod('POST');
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        documentalResponse = (HDT_WRP_DocumentalResponse) JSON.deserialize(res.getBody(), HDT_WRP_DocumentalResponse.class);
        documentalResponse.responseCode = res.getBody();
        documentalResponse.responseStatus =  res.getStatusCode();        
        return documentalResponse;
   }
}