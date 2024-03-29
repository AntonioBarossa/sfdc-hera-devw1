public with sharing class HDT_WS_CampagenDmDmpDataRequest  extends HDT_WS_Request {
    @AuraEnabled Public String runId;
    @AuraEnabled Public String status;
    @AuraEnabled Public String fileType;
    @AuraEnabled Public String description;
    @AuraEnabled Public List<String> contentVersionIds = new List<String>();
    public HDT_WS_CampagenDmDmpDataRequest(String runId,String Status,String fileType,String errorMessage,List<String> contentVersionIds) {
        System.debug('HDT_WS_CampagenDmDmpDataRequest');
        this.runId              = runId;
        this.Status             = Status;
        this.fileType           = fileType;
        this.contentVersionIds  = String.isBlank(errorMessage)?contentVersionIds:new List<String>();
        this.description        = String.isBlank(errorMessage)?'':errorMessage;
    }
}
