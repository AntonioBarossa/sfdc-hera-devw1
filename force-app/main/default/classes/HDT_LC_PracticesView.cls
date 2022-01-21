public inherited sharing class HDT_LC_PracticesView {

    @AuraEnabled
    public static HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj getTableConfig(String recordId, String type){
        HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj retObj;
        retObj = HDT_SRV_PracticesView.getTableConfigHelper(recordId, type, retObj);
        return retObj;
    }
    
    // Action method
    @AuraEnabled(continuation=true cacheable=true)
    public static Object startRequest(String recordId, String type) {
        return HDT_SRV_PracticesView.startRequestHelper(recordId, type);
    }
    
    // Callback method
    @AuraEnabled(cacheable=true)
    public static Object processResponse(List<String> labels, Object state) {
        return HDT_SRV_PracticesView.processResponseHelper(labels, state);
    }

}