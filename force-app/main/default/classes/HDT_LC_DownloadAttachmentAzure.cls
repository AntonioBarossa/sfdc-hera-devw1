/**
 * @description HDT_LC_DownloadAttachmentAzure
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_LC_DownloadAttachmentAzure {

    /**
     * @description HDT_LC_DownloadAttachmentAzure.getUrlNameDocumentLink
     * param rId - String
     * @return String
     */
    @AuraEnabled
    public static String getUrlNameDocumentLink(String rId){
        try {
            if (Schema.sObjectType.SiebelDocumentLink__x.fields.FILE_NAME__c.isAccessible()) {
                // Update contact phone number
                return '';
             }
            return [SELECT FILE_NAME__c FROM SiebelDocumentLink__x WHERE ID =:rId LIMIT 1].FILE_NAME__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
