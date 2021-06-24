public with sharing class HDT_WS_PaperProcessing {
    @AuraEnabled
    public static HDT_WS_Response postPaperProcessing(String filezipName, String type, String contentVersionId) {
        HDT_WS_PaperProcessingRequest req = new HDT_WS_PaperProcessingRequest(filezipName, type, contentVersionId);
		HDT_WS_Response res = HDT_WS_HTTPServiceCall.sendRequest('postPaperProcessing', req, HDT_WS_Response.class);
        return res;
    }
}