public with sharing class HDT_LC_AttachmentManager {

    @AuraEnabled
    public String  accountType {get;set;}
    
    @AuraEnabled
    public String  contactChannel {get;set;}
    
    @AuraEnabled
    public String  city {get;set;}

    @AuraEnabled
    public String  cluster {get;set;}

    @AuraEnabled
    public String  processType {get;set;}

    @AuraEnabled
    public String  subProcessType {get;set;}

    @AuraEnabled
    public String  productCode {get;set;}

    @AuraEnabled
    public String  SubscriberType {get;set;}
    
    @AuraEnabled
    public static String getAdditionalAttachment(Id recordId){
        String nameObject = recordId.getSObjectType().getDescribe().getName();
        if('Case'.equalsIgnoreCase(nameObject)){
            Case recordAdditional = [SELECT Id, AdditionalAttachments__c
                                        FROM Case
                                        WHERE Id =: recordId
                                        WITH SECURITY_ENFORCED];
            return recordAdditional.AdditionalAttachments__c;
        } else if('Order'.equalsIgnoreCase(nameObject)){
            Order recordAdditional = [SELECT Id, AdditionalAttachments__c
                                        FROM Order
                                        WHERE Id =: recordId
                                        WITH SECURITY_ENFORCED];
            return recordAdditional.AdditionalAttachments__c;
        }else {
            return null;
        }
        

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
/*
    @AuraEnabled
    public static Boolean updateAttachment(Id recordId, String required, String additional){
        try{
            if('Case'.equalsIgnoreCase(sobjectType.getDescribe().getName())){
                Case toUpdRecord = new Case(Id = recordId, AttachmentsStringTARI__c = required, AdditionalAttachments__c = additional);
            } else if('Order'.equalsIgnoreCase(sobjectType.getDescribe().getName())){
                Order toUpdRecord = new Order(Id = recordId, MandatoryAttachments__c = required, AdditionalAttachments__c = additional);
            }
            system.debug('@@@@: '+toUpdRecord);
            upsert toUpdRecord;
            return true;
        }catch(exception e){
            system.debug(e);
            return false;
        }
    }
*/

    @AuraEnabled
    public static String getRequiredAttachment(Id recordId, HDT_LC_AttachmentManager paramsWrap){
        /*
        Object tabellaAllegati = null; // Implementare la chiamata alla tabella degli allegati obbligatori con tutti i driver necessari
        return tabellaAllegati?.requiredAttachment;
        */
        return 'Patente; Modulo Variazione Superficie; Atto di Proprietà';
        //return '';
    }


}