/**
 * @description HDT_LC_DownloadAttachmentAzure
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_LC_DownloadAttachmentAzure {

    /**
     * @description HDT_LC_DownloadAttachmentAzure.getUrlNameDocumentLink
     * @param rId - String
     * @return String
     */
    @AuraEnabled
    public static String getUrlNameDocumentLink(String rId){
        try {
            //if (Schema.sObjectType.SiebelDocumentLink__x.fields.FILE_NAME__c.isAccessible()) {
            //    // Update contact phone number
            //    return '';
            // }
            return [SELECT NOME_FILE_DOWNLOAD__c FROM SiebelDocumentLink__x WHERE ID =:rId LIMIT 1].NOME_FILE_DOWNLOAD__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @description HDT_LC_DownloadAttachmentAzure.getExtensionFile
     * @param rId - String
     * @return Boolean, se 'url' o '' = false, else = true
     */
    @AuraEnabled
    public static Boolean getExtensionFile(String rId){
        try {
            String extension = [SELECT FILE_EXT__c FROM SiebelDocumentLink__x WHERE ID =:rId LIMIT 1].FILE_EXT__c; //get estensione
            if('URL'.equalsIgnoreCase(extension) || ''.equalsIgnoreCase(extension)){    //check estensione
                return false;
            }else{
                return true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}