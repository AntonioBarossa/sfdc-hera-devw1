public inherited sharing class HDT_LC_PracticesView {

    @AuraEnabled
    public static HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj getTableConfig(String recordId, String type){
        HDT_WRP_Practices.HDT_WRP_ReturnMetadataObj retObj;
        retObj = HDT_SRV_PracticesView.getTableConfigHelper(recordId, type, retObj);
        return retObj;
    }
 
    @AuraEnabled
    public static Object callWebService(String recordId, String type) {
        return HDT_SRV_PracticesView.callWebService(recordId, type);
    }

}