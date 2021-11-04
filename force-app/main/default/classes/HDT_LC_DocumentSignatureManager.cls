public with sharing class HDT_LC_DocumentSignatureManager {
    
    @AuraEnabled
    public static String previewDocumentFile(String recordId,String context,String formParams){
        String base64 = HDT_SRV_DocumentalManagementFacade.getBase64(recordId, context,formParams);
        return base64;
    }
    @AuraEnabled
    public static void sendDocumentFile(String recordId,String context,String formParams){
        HDT_SRV_DocumentalManagementFacade.sendDocumentAsync(recordId, context,formParams);
        HDT_SRV_DocumentalManagementFacade.checkEnvelopeForDiscard(recordId, formParams);
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

    @AuraEnabled
    public static void sendAdvanceDocumentation(String recordId,String context,String formParams){
        try {
            HDT_SRV_DocumentalManagementFacade.sendAdvanceDocumentation(recordId, context, formParams);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getInfoAccountStatement(String accountId){
        String jsonReturn;
        try {
            jsonReturn = HDT_SRV_DocumentalManagementFacade.getInfoAccountStatement(accountId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return jsonReturn;
    }
    
    @AuraEnabled
    public static string showOriginalDocument(String recordId){
        String serializedOutput = HDT_SRV_DocumentalManagementFacade.showOriginalDocument(recordId);
        return serializedOutput;
    }

    @AuraEnabled
    public static string showArchivedAttachment(String recordId){
        String serializedOutput = HDT_SRV_DocumentalManagementFacade.showArchivedAttachment(recordId);
        return serializedOutput;
    }

    @AuraEnabled
    public static string resendDocusignEnvelope(String recordId){
        String serializedOutput = HDT_SRV_DocumentalManagementFacade.resendDocusignEnvelope(recordId);
        return serializedOutput;
    }
}