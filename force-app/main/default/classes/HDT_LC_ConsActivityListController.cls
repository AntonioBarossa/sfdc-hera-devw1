public inherited sharing class HDT_LC_ConsActivityListController {

    @AuraEnabled
    public static HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj getTableConfig(String type){
        HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj retObj;
        return HDT_LC_AccountDataEnrichmentHelper.getTableConfigHelper(null, type, retObj);
    }

    // Action method
    @AuraEnabled(continuation=true cacheable=true)
    public static Object startRequest(String type, String requestObj) {
        return HDT_UTL_ConsActivityListController.startRequestHelper(type, requestObj);
    }
    
    // Callback method
    @AuraEnabled(cacheable=true)
    public static Object processResponse(List<String> labels, Object state) {
        return HDT_UTL_ConsActivityListController.processResponseHelper(labels, state);
    }

}