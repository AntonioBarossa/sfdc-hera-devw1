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
    public static List<ContentDocument> getRecordsById(Id recordId){

        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('ContentDocumentLink','ContentDocumentId','read');
        securityClass.checkSecurityAccess();
        List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
        
        if (cdLs.size() < 1){
            return new List<ContentDocument>();
        }

        // Make a List of ContentDocument IDs
        List <Id> cdIdList = new List <Id> ();

        for (ContentDocumentLink nextCdl : cdLs) {
            cdIdList.add(nextCdl.ContentDocumentId); 
        }        

        List<ContentDocument> contentDocuments = [SELECT Id, Title, FileType,CreatedDate FROM ContentDocument WHERE ContentDocument.Id IN :cdIdList WITH SECURITY_ENFORCED];
        
        return contentDocuments;
        
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
