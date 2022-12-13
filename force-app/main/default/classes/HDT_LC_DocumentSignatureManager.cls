public with sharing class HDT_LC_DocumentSignatureManager {
    
    @AuraEnabled
    public static String previewDocumentFile(String recordId,String context,String formParams){
        String base64 = HDT_SRV_DocumentalManagementFacade.getBase64(recordId, context,formParams);
        return base64;
    }
    @AuraEnabled
    public static void sendDocumentFile(String recordId,String context,String formParams){
        if( 'Order'.equalsIgnoreCase(context) )
        {
            createActivityForChangeAddress(recordId);
        }
        HDT_SRV_DocumentalManagementFacade.sendDocumentAsync(recordId, context,formParams);
        HDT_SRV_DocumentalManagementFacade.checkEnvelopeForDiscard(recordId, formParams);
        HDT_UTL_Scarti.closeDocumentalManagementActivity(formParams);
    }

    @future
    public static void createActivityForChangeAddress(String recordId){
        List<Order> ordIdList = [ SELECT Id FROM Order WHERE ParentOrder__c = :recordId 
                                            AND ServicePoint__r.IsAddressChanged__c = true 
                                            AND ( Process__c = 'Subentro' OR Process__c = 'Subentro Cambio Cat.Tariffa' ) WITH SECURITY_ENFORCED ];
        
        if ( !ordIdList.isEmpty())
        {
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.Order__c = ordIdList[0].Id;
            activity.Type__c = 'Modifica Indirizzo Fornitura';
            HDT_UTL_DatabaseService.insertSObject(activity);
        }
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

    @AuraEnabled
    public static string handleContactPoint(String email, String phone, String contactId, String mode){
        String serializedOutput = HDT_SRV_DocumentalManagementFacade.handleContactPoint(email, phone, contactId, mode);
        return serializedOutput;
    }
}