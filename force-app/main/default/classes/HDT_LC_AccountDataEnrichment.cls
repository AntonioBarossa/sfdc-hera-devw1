public inherited sharing class HDT_LC_AccountDataEnrichment {

    @AuraEnabled
    public static HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj getTableConfig(String recordId, String type){
        HDT_WRP_AccountDataEnrichment.HDT_WRP_ReturnMetadataObj retObj;
        retObj = HDT_LC_AccountDataEnrichmentHelper.getTableConfigHelper(recordId, type, retObj);
        return retObj;
    }
    
    // Action method
    @AuraEnabled(continuation=true cacheable=true)
    public static Object startRequest(String recordId, String type) {
        return HDT_LC_AccountDataEnrichmentHelper.startRequestHelper(recordId, type);
    }
    
    // Callback method
    @AuraEnabled(cacheable=true)
    public static Object processResponse(List<String> labels, Object state) {
        return HDT_LC_AccountDataEnrichmentHelper.processResponseHelper(labels, state);
    }

}