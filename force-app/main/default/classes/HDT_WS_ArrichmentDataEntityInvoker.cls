public class HDT_WS_ArrichmentDataEntityInvoker {
    private static final String REQUEST_PATH = '/data-enrichment/entities';

    @AuraEnabled
    public static HDT_WS_ArrichmentDataEntityResponse callService(String contratto, String pod){
        
        HDT_WS_ArrichmentDataEntityRequest req = new HDT_WS_ArrichmentDataEntityRequest(pod, contratto);
		HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WS_ArrichmentDataEntityResponse.class);
        
        return res;
    }

    @AuraEnabled
    public static HDT_WS_ArrichmentDataEntityResponse callService(String contratto, String pod, String impianto){
        
        HDT_WS_ArrichmentDataEntityRequest req = new HDT_WS_ArrichmentDataEntityRequest(pod, contratto,impianto);
		HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WS_ArrichmentDataEntityResponse.class);
        
        return res;
    }

    @InvocableMethod(label='Invoke Data Enrichment')
    public static List<String> submitEnrichmentRequest(List<HDT_WRP_ArricchimentoFlowInputs> request){
 
        List<String> ret = new List<String>(); 
        System.debug('invocable method params: '+request);
        HDT_WS_ArrichmentDataEntityResponse res = callService(request[0].contractCode,request[0].pod ,request[0].impianto); //
        
        System.debug(res);

        if(res.statusCode != 200){
            ret.add('');
            return ret;
        }
        ret.add(JSON.serialize(res)); 
        
        return ret;
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
}