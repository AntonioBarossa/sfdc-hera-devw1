public class HDT_WS_ArrichmentDataEntityInvoker {
    
    @AuraEnabled
    public static HDT_WS_ArrichmentDataEntityResponse callService(String contratto,String pod){
        
        HDT_WS_ArrichmentDataEntityRequest req = new HDT_WS_ArrichmentDataEntityRequest(pod,contratto);
		HDT_WS_ArrichmentDataEntityResponse res = (HDT_WS_ArrichmentDataEntityResponse)HDT_WS_HTTPServiceCall.sendRequest('ArrichData.Entity', req,HDT_WS_ArrichmentDataEntityResponse.class);
        
        return res;
    }
}