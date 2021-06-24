public with sharing class HDT_LC_DownloadAttachmentAzure {
    
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
