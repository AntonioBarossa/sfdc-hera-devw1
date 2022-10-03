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
}