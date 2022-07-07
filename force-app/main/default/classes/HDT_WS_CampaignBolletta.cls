public with sharing class HDT_WS_CampaignBolletta {
    private static final String REQUEST_PATH = '/commercial-codes'; 
    @AuraEnabled
    public static HDT_WS_Response channelBolletta(list<HDT_WS_CampaignBollettaRequest> req) {
		HDT_WS_Response res = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WS_Response.class);
        return res;
    }

    
    public class HDT_WS_CampaignBollettaRequest extends HDT_WS_Request {
        @AuraEnabled public String campaignId {get;set;}
        @AuraEnabled public String campaignName {get;set;}
        @AuraEnabled public String campaignDescription {get;set;}
        @AuraEnabled public String contractCode {get;set;}
        @AuraEnabled public String comunicationText {get;set;}
    }
    
    public class HDT_WS_CampaignBollettaRequestWrap {
        @AuraEnabled public String campaignId {get;set;}
        @AuraEnabled public String campaignName {get;set;}
        @AuraEnabled public String campaignDescription {get;set;}
        @AuraEnabled public String contractCode {get;set;}
        @AuraEnabled public String comunicationText {get;set;}
        
    }
}
