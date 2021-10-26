/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 04/08/2021
* @description HDT_SRV_ContentDocumentLink
* @history Lorenzo – 04/08/2021 – created class
*/
public with sharing class HDT_SRV_ContentDocumentLink {
    public ContentDocumentLink createRecord(String linkedEntityId, String contentDocumentId, String shareType) {
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = linkedEntityId;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.shareType = shareType;
        HDT_UTL_DatabaseService.insertSObject(cdl);
        return cdl;
        
    }

    public ContentDocumentLink createRecordNoInsert(String linkedEntityId, String contentDocumentId, String shareType) {
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = linkedEntityId;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.shareType = shareType;
       // HDT_UTL_DatabaseService.insertSObject(cdl);
        return cdl;
        
    }

    public List<ContentDocumentLink> insertRecords(List<ContentDocumentLink> listContent) {
        HDT_UTL_DatabaseService.insertSObject(listContent);
        return listContent;
        
    }
}