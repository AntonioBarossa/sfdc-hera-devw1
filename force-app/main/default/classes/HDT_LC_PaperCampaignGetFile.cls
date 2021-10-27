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
    public static Boolean createPaperFile(String fileBase64, String paperId, String filename){
        try {
            List<PaperCommunication__c> paperList = new List<PaperCommunication__c>();
            //create content version
            ContentVersion cv = HDT_UTL_DocumentalManagement.createContectVersion(fileBase64, filename);
            system.debug('ContentVersion: ' + cv);
            //create content document link
            ContentDocumentLink cdl =  HDT_UTL_DocumentalManagement.createContentLink(cv.Id, paperId);
            system.debug('ContentDocumentLink ' + cdl);
            if (cdl != null) {
                return true;
            }
            return false;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
