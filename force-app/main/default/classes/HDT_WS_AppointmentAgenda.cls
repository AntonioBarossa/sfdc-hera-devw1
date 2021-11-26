@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_WS_AppointmentAgenda {
    private final String REQUEST_PATH = '/appointment/request/create'; 
    
    public HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento executeRequest(String body) {
        String debugString = 'HDT_WS_AppointmentAgenda - executeRequest ';
        HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento response = new HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento();
        System.debug(LoggingLevel.DEBUG, debugString + 'Body : '+body);
        String errorResponse = '';
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('Callout:HerokuBasePath'+this.REQUEST_PATH);
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(LoggingLevel.DEBUG, debugString + 'response ' +  res);
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug(LoggingLevel.DEBUG, debugString + 'response body : ' +  res.getBody());
            if (responseBodyMap.containsKey('responseAppuntamento')) {
                System.debug(LoggingLevel.DEBUG, debugString + 'response element ' +  JSON.serialize(responseBodyMap.get('responseAppuntamento')));
                response = (HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento) JSON.deserialize(JSON.serialize(responseBodyMap.get('responseAppuntamento')), HDT_WRP_Appuntamento.HDT_WRP_ResponseAppuntamento.class);
            }
            if (response == null){
                errorResponse = 'Nessuno slot è stato ricevuto dal server';
            }else if (res.getStatusCode() < 200 || res.getStatusCode() > 300){
                //verificare se il campo response.errInvioDis ritorna la descrizione dell'errore;
                errorResponse = 'Messaggio ricevuto dal server: '+response.errInvioDis+' [Status code: '+res.getStatusCode()+']';
            }        
        } catch (Exception ex) {
            System.debug(LoggingLevel.DEBUG, 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
            errorResponse = 'Errore WS ' + ex.getMessage() + ' at line ' + ex.getLineNumber();
        }
        if (String.isNotEmpty(errorResponse)){
            throw new HDT_UTL_HeraException(errorResponse);
        }
        return response;
    }
        
}
