public with sharing class HDT_LC_AttachmentManager {
    
    @AuraEnabled
    public static Map<String,String> getAttachmentInfoFromCase(Id caseId){
        Map<String,String> mapFields = new Map<String,String>();
        Case recordCase = [SELECT Id, AdditionalAttachments__c, AttachmentsStringTARI__c
                            FROM Case
                            WHERE Id =: caseId
                            WITH SECURITY_ENFORCED];
        mapFields.put('required' , recordCase.AttachmentsStringTARI__c);
        mapFields.put('optional' , recordCase.AdditionalAttachments__c);
        return mapFields;

    }

    @AuraEnabled
    public static String getRequiredAttachmentFromCase(Id caseId, String process, String subProcess, String personType){
        /*
        Object tabellaAllegati = null; // Implementare la chiamata alla tabella degli allegati obbligatori con tutti i driver necessari
        return tabellaAllegati?.requiredAttachment;
        */
        return 'Patente; Modulo Variazione Superficie; Atto di Proprietà';
    }


}
