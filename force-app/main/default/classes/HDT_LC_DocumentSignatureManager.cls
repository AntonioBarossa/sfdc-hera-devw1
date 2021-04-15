public with sharing class HDT_LC_DocumentSignatureManager {
    
    @AuraEnabled
    public static String previewDocumentFile(String recordId,String context,String formParams){
        String base64 = HDT_SRV_DocumentalManagementFacade.getBase64(recordId, context,formParams);
        return base64;
    }

    @AuraEnabled
    public static string getSignSendMode(String processType, String source){
        String jsonReturn;
        try {
            jsonReturn = HDT_SRV_DocumentalManagementFacade.getSignSendMode(processType, source);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return jsonReturn;
    }
}