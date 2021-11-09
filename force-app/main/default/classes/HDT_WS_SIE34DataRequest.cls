public with sharing class HDT_WS_SIE34DataRequest  extends HDT_WS_Request {
    @AuraEnabled Public String runId;
    @AuraEnabled Public String status;
    @AuraEnabled Public String fileType;
    @AuraEnabled Public String description;
    @AuraEnabled Public List<String> contentVersionIds = new List<String>();
    public HDT_WS_SIE34DataRequest(String runId,String Status,String fileType,String errorMessage,List<String> contentVersionIds) {
        //System.debug('HDT_WS_SIE34DataRequest');
        this.runId              = runId;
        this.Status             = Status;
        this.fileType           = fileType.replaceAll('SIE', '');
        this.contentVersionIds  = (String.isBlank(errorMessage)||contentVersionIds==null)?contentVersionIds:new List<String>();
        this.description        = String.isBlank(errorMessage)?'':errorMessage;
    }
}
