public with sharing class HDT_LC_AttachmentManager {
    
    @AuraEnabled
    public static String getAdditionalAttachmentFromCase(Id caseId){

        Case recordCase = [SELECT Id, AdditionalAttachments__c
                            FROM Case
                            WHERE Id =: caseId
                            WITH SECURITY_ENFORCED];
        return recordCase.AdditionalAttachments__c;

    }

    @AuraEnabled
    public static Boolean updateAttachment(Id caseId, String required, String additional){
        try{
            Case recordCase = new Case(Id = caseId, AttachmentsStringTARI__c = required, AdditionalAttachments__c = additional);
            update recordCase;
            return true;
        }catch(exception e){
            system.debug(e);
            return false;
        }
    }

    @AuraEnabled
    public static String getRequiredAttachmentFromCase(Id caseId){
        /*
        Object tabellaAllegati = null; // Implementare la chiamata alla tabella degli allegati obbligatori con tutti i driver necessari
        return tabellaAllegati?.requiredAttachment;
        */
        return 'Patente; Modulo Variazione Superficie; Atto di Proprietà';
    }


}
