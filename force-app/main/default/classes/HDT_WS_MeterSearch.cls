@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_WS_MeterSearch {
    public static HDT_WRP_MeterSearchResponse submitRequest(String body){
        HDT_WRP_MeterSearchResponse response = new HDT_WRP_MeterSearchResponse();

        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:MeterSearch');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(LoggingLevel.DEBUG, 'response: ' + res.getBody());
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('data')) {
                System.debug(LoggingLevel.DEBUG, JSON.serialize(responseBodyMap.get('data')));
                response = (HDT_WRP_MeterSearchResponse) JSON.deserialize(JSON.serialize(responseBodyMap.get('data')), HDT_WRP_MeterSearchResponse.class);
            }
            response.responseCode = res.getStatusCode();
            response.responseStatus =  res.getStatus();

        } catch (CalloutException ce) {
            System.debug(LoggingLevel.DEBUG, 'CalloutException: ' + ce.getStackTraceString());
        } catch (Exception e){
            System.debug(LoggingLevel.DEBUG, 'Errore WS: ' + e.getStackTraceString());
        }

        return response;
    }
}
