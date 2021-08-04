public with sharing class HDT_SRV_ContentDocumentLink {
    public ContentDocumentLink createRecord(String linkedEntityId, String contentDocumentId, String shareType) {
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = linkedEntityId;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.shareType = shareType;
        HDT_UTL_DatabaseService.insertSObject(cdl);
        return cdl;
        
    }
}