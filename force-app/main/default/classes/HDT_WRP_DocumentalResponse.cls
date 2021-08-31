public with sharing class HDT_WRP_DocumentalResponse {
    public HDT_WRP_DocumentalResponse() {
        this.deliverPackageResponse = new HDT_WRP_DocumentalResponseRoot();
    }
    public Integer responseCode;
    public String responseStatus;
    public HDT_WRP_DocumentalResponseRoot deliverPackageResponse;
    

    public class HDT_WRP_DocumentalResponseAttachment{
        public String code;
        public String type;
        public String version;
        public String mandatory;
        public String signature;
        public HDT_WRP_DocumentalResponseAttachment(){}
    }

    public class HDT_WRP_DocumentalResponseServiceItem{
        public String serviceId;
        public String attachId;
        public String attachName;
        public String attachVersion;
        public List<HDT_WRP_DocumentalResponseAttachment> attachmentList;
    }

    public class HDT_WRP_DocumentalResponseRoot{
        public String composedDocument;
        public String requestId;
        public String packageIds;
        public String archive;
        public String result;
        public String message;
        public List<HDT_WRP_DocumentalResponseServiceItem> serviceList;
    }

    public class HDT_WRP_PostelResponse{
        public Integer responseCode;
        public String responseStatus;
        public String content;
    }

    public class HDT_WRP_IntesaResponse{
        public Integer responseCode;
        public String responseStatus;
    }
}