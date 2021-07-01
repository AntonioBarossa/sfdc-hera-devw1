public class HDT_WS_PaperProcessingRequest extends HDT_WS_Request {
    @AuraEnabled Public String filezipName;
    @AuraEnabled Public String type;
    @AuraEnabled Public List<HDT_WRP_ContentVersion> contentVersion;

    public class HDT_WRP_ContentVersion {
        @AuraEnabled public String contentVersionId { get; set;}
    }

    public HDT_WS_PaperProcessingRequest(String filezipName, String type, String contentVersionId){
        this.filezipName = filezipName;
        this.type = type;
        HDT_WRP_ContentVersion obj = new HDT_WRP_ContentVersion();
        obj.contentVersionId = contentVersionId;
        List<HDT_WRP_ContentVersion> contentVersionList = new List<HDT_WRP_ContentVersion>();
        contentVersionList.add(obj);
        this.contentVersion = contentVersionList;
    }
    public HDT_WS_PaperProcessingRequest(String filezipName, String type, List<String> contentVersionId){
        this.filezipName = filezipName;
        List<HDT_WRP_ContentVersion> contentVersionList = new List<HDT_WRP_ContentVersion>();
        this.type = type;
        for(String s : contentVersionId){
            HDT_WRP_ContentVersion obj = new HDT_WRP_ContentVersion();
            obj.contentVersionId = s;
            contentVersionList.add(obj);
        }
        this.contentVersion = contentVersionList;
    }
}