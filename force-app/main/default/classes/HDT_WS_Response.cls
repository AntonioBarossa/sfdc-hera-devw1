public virtual class HDT_WS_Response {

    @AuraEnabled public Integer statusCode;
    @AuraEnabled public String body;
    @AuraEnabled public String status;
    @AuraEnabled public String errorDetails;
    @AuraEnabled public String exceptionMessage;
}