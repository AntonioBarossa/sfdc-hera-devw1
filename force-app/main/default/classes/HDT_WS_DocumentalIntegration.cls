public with sharing class HDT_WS_DocumentalIntegration {
    public static HDT_WRP_DocumentalResponse submitRequest(String body){
        HDT_WRP_DocumentalResponse documentalResponse = new HDT_WRP_DocumentalResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:Engage1');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('data')) {
                System.debug(JSON.serialize(responseBodyMap.get('data')));
                documentalResponse = (HDT_WRP_DocumentalResponse) JSON.deserialize(JSON.serialize(responseBodyMap.get('data')), HDT_WRP_DocumentalResponse.class);
            }
            documentalResponse.responseCode = res.getStatusCode();
            documentalResponse.responseStatus =  res.getStatus();             
        }catch(Exception ex){
            System.debug('Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }     
        return documentalResponse;
   }
}