public with sharing class HDT_LC_PaperCampaignGetFile {
    public static HDT_SRV_ContentVersion contentVersionSrv = new HDT_SRV_ContentVersion();

    @AuraEnabled(cacheable=true)
    public static PaperCommunication__c getPaperCommunicationRecord(String id){
        try {
            PaperCommunication__c p = HDT_QR_PaperCommunication.getRecordById(id);
            return p;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getIdByName(String filename){
        try {
            HDT_WS_PaperCampaignGetFile.wrapResponseGetId result = HDT_WS_PaperCampaignGetFile.callServiceGetIdByName(filename);
            return JSON.serialize(result);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getFileById(String documentId){
        try {
            HDT_WS_PaperCampaignGetFile.wrapResponseGetFile result = HDT_WS_PaperCampaignGetFile.callServiceGetFileById(documentId);
            return JSON.serialize(result);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createPaperFile(String fileBase64, String paperId, String filename){
        try {
            //create content version
            ContentVersion cv = HDT_UTL_DocumentalManagement.createContectVersion(fileBase64, filename);
            //create content document link
            ContentDocumentLink cdl =  HDT_UTL_DocumentalManagement.createContentLink(cv.Id, paperId);
            if (cdl != null) {
                //return true;
                return cdl.ContentDocumentId ;
            }
           // return false;   
           return null;         
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkPaperFile( String paperId, String filename){
        try {
           List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
            cdl = [select Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title 
                                        from ContentDocumentLink where LinkedEntityId =:paperId and ContentDocument.Title =:filename WITH SECURITY_ENFORCED LIMIT 1];
            if (cdl != null && cdl.size()>0) {
                return true;
            }
            return false;                 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}