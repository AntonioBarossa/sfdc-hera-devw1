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
    public static Map<String,String> getUrlNameDocumentLink(String rId){
        try {
            //if (Schema.sObjectType.SiebelDocumentLink__x.fields.FILE_NAME__c.isAccessible()) {
            //    // Update contact phone number
            //    return '';
            // }
            //START Modifica>>> marco.arci@webresults.it 10/11/21
            SiebelDocumentLink__x objectDLink = [SELECT NOME_FILE_DOWNLOAD__c, FILE_NAME__c, FILE_EXT__c FROM SiebelDocumentLink__x WHERE ID =:rId WITH SECURITY_ENFORCED LIMIT 1];
            Map<String,String> nameFile = new Map<String,String>();
            nameFile.put('NOME_FILE_DOWNLOAD__c', objectDLink.NOME_FILE_DOWNLOAD__c);
            nameFile.put('FILE_NAME__c', objectDLink.FILE_NAME__c);
            nameFile.put('FILE_EXT__c', objectDLink.FILE_EXT__c);
            return nameFile;
            //END Modifica>>> marco.arci@webresults.it 10/11/21
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
            
            //String extension = [SELECT FILE_EXT__c FROM SiebelDocumentLink__x WHERE ID =:rId];	//get estensione
            
            List<SiebelDocumentLink__x> records = HDT_UTL_ObjectManagerTst.records([SELECT FILE_EXT__c FROM SiebelDocumentLink__x WHERE ID =:rId]);
            String extension = (String)records[0].get('FILE_EXT__c');
            
            
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