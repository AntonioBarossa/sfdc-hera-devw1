/**
 * @description       : 
 * @last modified on  : 05-11-2021
**/
public with sharing class HDT_QR_ContentDocument {

    public List<ContentDocument> getRecordsByTitle(String contentDocumentTitle) {
        return [SELECT Id, Title,CreatedDate FROM ContentDocument 
                WHERE Title =: contentDocumentTitle
                WITH SECURITY_ENFORCED];
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

}
