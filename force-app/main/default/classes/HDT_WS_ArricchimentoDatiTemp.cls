public with sharing class HDT_WS_ArricchimentoDatiTemp {
    @InvocableMethod(label='Invoke Data Enrichment')
    public static List<String> submitRequest(List<HDT_WRP_ArricchimentoFlowInputs> request) {
        List<String> serializedResponse = new List<String>();
        //Map<String,String> bodyMap = new Map<String,String>{'pod' => request[0].pod,'contratto'=>request[0].contractCode};
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('pod', request[0].pod != null?request[0].pod:'');
        gen.writeStringField('contratto', request[0].contractCode!=null?request[0].contractCode:'');
        gen.writeEndObject();
        String pretty = gen.getAsString();
        System.debug(pretty);
        HttpRequest req = new HttpRequest();
        HDT_WRP_ArricchimentoResponse arricchimentoResponse = new HDT_WRP_ArricchimentoResponse();
        try {
            req.setEndpoint('Callout:ArricchimentoDatiTemp');
            req.setMethod('POST');
            req.setBody(pretty);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            arricchimentoResponse = (HDT_WRP_ArricchimentoResponse) JSON.deserialize(res.getBody(), HDT_WRP_ArricchimentoResponse.class);
            System.debug(arricchimentoResponse.data.posizioni);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        serializedResponse.add(JSON.serialize(arricchimentoResponse.data.posizioni));
        return serializedResponse;
    }

    // Richiama il WS di Arricchimento Dati
    // pod = codice pod/pdr del Service Point
    // contractCode = codice contratto sap afferente al service point.
    public static String submitRequest(String pod, String contractCode) {
        List<String> serializedResponse = new List<String>();
        //Map<String,String> bodyMap = new Map<String,String>{'pod' => request[0].pod,'contratto'=>request[0].contractCode};
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('pod', pod != null ? pod : '');
        gen.writeStringField('contratto', contractCode != null ? contractCode : '');
        gen.writeEndObject();
        String pretty = gen.getAsString();
        System.debug(pretty);
        HttpRequest req = new HttpRequest();
        HDT_WRP_ArricchimentoResponse arricchimentoResponse = new HDT_WRP_ArricchimentoResponse();
        try {
            req.setEndpoint('Callout:ArricchimentoDatiTemp');
            req.setMethod('POST');
            req.setBody(pretty);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            arricchimentoResponse = (HDT_WRP_ArricchimentoResponse) JSON.deserialize(res.getBody(), HDT_WRP_ArricchimentoResponse.class);
            System.debug(arricchimentoResponse.data.posizioni);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        return JSON.serialize(arricchimentoResponse.data.posizioni);
    }
    
    //input details that comes to apex from flow
    public class HDT_WRP_ArricchimentoFlowInputs{
    
        @InvocableVariable
        public String contractCode;
        
        @InvocableVariable
        public String pod;
        
    }
    

    public class HDT_WRP_ArricchimentoTestata{
        public String esito;
    }
    
    public class HDT_WRP_ArricchimentoPosizioni{
        @InvocableVariable
        public String campo;
        @InvocableVariable
        public String valore;
    }
    
    public class HDT_WRP_ArricchimentoData{
        public HDT_WRP_ArricchimentoTestata testata;
        public List<HDT_WRP_ArricchimentoPosizioni> posizioni;
    }
    
    public class HDT_WRP_ArricchimentoResponse{
        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_ArricchimentoData data;
    }
}