public class HDT_WS_ArrichmentDataEntityRequest extends HDT_WS_Request{
	@AuraEnabled Public String pod;
    @AuraEnabled Public String contratto;
    
    public HDT_WS_ArrichmentDataEntityRequest(String pod,String contratto){
        this.pod = pod;
        this.contratto = contratto;
    }
}