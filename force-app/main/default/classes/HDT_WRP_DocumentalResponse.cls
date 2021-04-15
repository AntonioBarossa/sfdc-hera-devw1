public with sharing class HDT_WRP_DocumentalResponse {
    public HDT_WRP_DocumentalResponse() {

    }
    public String responseCode;
    public Integer responseStatus;
    public String composedDocument;
    public String requestId;
    public String packageId;
    public String archive;
    public String result;
    public String message;
    public List<HDT_WRP_DocumentalResponseAttachment> attachmentList;

    public class HDT_WRP_DocumentalResponseAttachment{
        public String code;
        public String version;
        public String description;
        public String required;
        public String requestId;
        public HDT_WRP_DocumentalResponseAttachment(){}
    }
}