public class HDT_WS_ArrichmentDataEntityRequest extends HDT_WS_Request{
	@AuraEnabled Public String pod;
    @AuraEnabled Public String contratto;
    @AuraEnabled Public String impianto;
    public HDT_WS_ArrichmentDataEntityRequest(String pod,String contratto){
        this.pod = pod;
        this.contratto = contratto;
    }

    public HDT_WS_ArrichmentDataEntityRequest(String pod,String contratto,String impianto){
        this.pod = pod;
        this.contratto = contratto;
        this.impianto = impianto;
    }
}