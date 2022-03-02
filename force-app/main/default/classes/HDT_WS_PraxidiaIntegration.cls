public with sharing class HDT_WS_PraxidiaIntegration {
    private static final String REQUEST_PATH = '/survey/files';
    @AuraEnabled
    public static HDT_WS_Response callService(String contentversionid,String surveyType){
        
        PraxidiaIntegrationRequest req = new PraxidiaIntegrationRequest(contentversionid,surveyType);
        HDT_WS_Response res = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req,HDT_WS_Response.class);
        
        return res;
    }
    
    public class PraxidiaIntegrationRequest extends HDT_WS_Request{
        public PraxidiaIntegrationRequest(String contentVersionId,String surveyType){
            this.contentVersionId = contentVersionId;
            this.surveyType = surveyType;
        }
        @AuraEnabled public String surveyType {get;set;}
        @AuraEnabled public String contentVersionId {get;set;}
    }
}