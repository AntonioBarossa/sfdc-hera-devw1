@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_WS_ArricchimentoDatiTemp {
    
    // Wrapper per i flow.
    @InvocableMethod(label='Invoke Data Enrichment')
    public static List<String> submitRequestFlow(List<HDT_WRP_ArricchimentoFlowInputs> request) {
        List<String> serializedResponse = new List<String>();

        String pod = request[0].pod;
        String contractCode = request[0].contractCode;
        String impianto = request[0].impianto;

        String arricchimentoResponse = submitRequest(pod, contractCode, impianto);

        serializedResponse.add(arricchimentoResponse);
        return serializedResponse;
    }

    // Richiama il WS di Arricchimento Dati
    // pod = codice pod/pdr del Service Point
    // contractCode = codice contratto sap afferente al service point.
    /*
    @Author:        Francesco Vitiello
    CreatedDate:    22/10/2021
    Reason: Avoid Debug Statements
    */

    public static String submitRequest(String pod, String contractCode)
    {
        return submitRequest(pod, contractCode, '');
    }

    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static String submitRequest(String pod, String contractCode, String impianto) {
        //List<String> serializedResponse = new List<String>();
        //Map<String,String> bodyMap = new Map<String,String>{'pod' => request[0].pod,'contratto'=>request[0].contractCode};
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('pod', pod != null ? pod : '');
        gen.writeStringField('contratto', contractCode != null ? contractCode : '');
        gen.writeStringField('impianto', impianto != null ? impianto : '');
        gen.writeEndObject();
        String pretty = gen.getAsString();
        System.debug(LoggingLevel.DEBUG, pretty);
        HttpRequest req = new HttpRequest();
        HDT_WS_ArrichmentDataEntityResponse arricchimentoResponse = new HDT_WS_ArrichmentDataEntityResponse();
        HDT_WRP_ArricchimentoData emptyData = new HDT_WRP_ArricchimentoData();
        List<HDT_WRP_ArricchimentoPosizioni> emptyPositions = new List<HDT_WRP_ArricchimentoPosizioni>();
        HDT_WRP_ArricchimentoPosizioni emptyPosition = new HDT_WRP_ArricchimentoPosizioni();
        HDT_WRP_ArricchimentoTestata emptyTestata = new HDT_WRP_ArricchimentoTestata();
        emptyTestata.esito = '';
        emptyPosition.campo = '';
        emptyPosition.valore= '';
        emptyPositions.add(emptyPosition);
        emptyData.posizioni = emptyPositions;
        emptyData.testata = emptyTestata;
        try {
            req.setEndpoint('Callout:ArricchimentoDatiTemp');
            req.setMethod('POST');
            req.setBody(pretty);
            req.setTimeout(120000);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            arricchimentoResponse = (HDT_WS_ArrichmentDataEntityResponse) JSON.deserialize(res.getBody(), HDT_WS_ArrichmentDataEntityResponse.class);
            System.debug(LoggingLevel.DEBUG, arricchimentoResponse.data.posizioni);
        } catch (Exception ex) {
            /*@frpanico created empty response to not undergo "Attempt To De-reference null object" */
            emptyTestata.esito = '';
            emptyPosition.campo = '';
            emptyPosition.valore= '';
            emptyPositions.add(emptyPosition);
            emptyData.posizioni = emptyPositions;
            emptyData.testata = emptyTestata;
           //System.debug(ex.getMessage());
        }
        if(arricchimentoResponse.data != null && arricchimentoResponse.data.posizioni != null)
        {
            return JSON.serialize(arricchimentoResponse.data.posizioni);
        }
        else
        {
           return '';
        }
    }
    
    //input details that comes to apex from flow
    public class HDT_WRP_ArricchimentoFlowInputs{
    
        @InvocableVariable
        public String contractCode;
        
        @InvocableVariable
        public String pod;

        @InvocableVariable
        public String impianto;
        
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
        public List<HDT_WRP_ArricchimentoDatiCatastali> datiCatastali;
    }
    
   /*  public class HDT_WRP_ArricchimentoResponse{
        public String status;
        public String correlationId;
        public String timestamp;
        public HDT_WRP_ArricchimentoData data;
    } */

    public class HDT_WRP_ArricchimentoDatiCatastali{
        public String destinazione;
        public String progressivo;
        public String codiceAssenzaDatiCatastali;
        public String comuneAmministrativo;
        public String comuneCatastale;
        public String codiceComuneCatastale;
        public String codiceProvincia;
        public String tipoUnita;
        public String sezioneUrbana;
        public String foglio;
        public String particella;
        public String subalterno;
        public String qualificaTitolareUtenza;
        public String superficeCatastale;
        public String categoriaCatastale;
   }
}