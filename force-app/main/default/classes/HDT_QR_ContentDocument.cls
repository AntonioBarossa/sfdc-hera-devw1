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

}
