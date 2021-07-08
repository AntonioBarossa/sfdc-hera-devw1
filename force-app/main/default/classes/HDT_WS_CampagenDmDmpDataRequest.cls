public with sharing class HDT_WS_CampagenDmDmpDataRequest  extends HDT_WS_Request {
    @AuraEnabled Public String runId;
    @AuraEnabled Public String fileType;
    @AuraEnabled Public List<String> contentVersionIds = new List<String>();
    public HDT_WS_CampagenDmDmpDataRequest(String runId,String fileType,List<String> contentVersionIds) {
        System.debug('HDT_WS_CampagenDmDmpDataRequest');
        this.runId=runId;
        this.fileType=fileType;
        this.contentVersionIds=contentVersionIds;

    }
}
