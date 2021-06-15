public with sharing class HDT_WRP_DocusignNotify {
    
    public class HDT_WRP_DocusignNotifyRequest{
        public String outcome;
        public String outcomeDescription;
        public String envelopeId;
        public String status;
        public Datetime sentDateTime;
        public Datetime completedDateTime;
        public List<HDT_WRP_DocusignNotifyData> listOfData;
    }

    public class HDT_WRP_DocusignNotifyData{
        public String dataName;
        public String dataCode;
        public String dataValue;
    }

    public class HDT_WRP_DocusignNotifyResponse{
        public String outcome;
        public String outcomeDescription;
    }
}
