public with sharing class HTD_LC_DownloadAttachmentAzure {
    
    @AuraEnabled
    public static String getUrlNameDocumentLink(String rId){
        try {
            return [SELECT FILE_NAME__c FROM SiebelDocumentLink__x WHERE ID =:rId LIMIT 1].FILE_NAME__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
