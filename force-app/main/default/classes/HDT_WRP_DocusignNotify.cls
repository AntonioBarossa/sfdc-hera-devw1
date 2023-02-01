public with sharing class HDT_WRP_DocusignNotify {
    
    public class HDT_WRP_DocusignNotifyRequest{
        public String outcome;
        public String outcomeDescription;
        public String envelopeId;
        public String status;
        public String declinedReason;
        public Datetime sentDateTime;
        public Datetime completedDateTime;
        public List<HDT_WRP_DocusignNotifyData> listOfDataText;
        public List<HDT_WRP_DocusignNotifyRadio> listOfRadioGroup;
    }

    public class HDT_WRP_DocusignNotifyData{
        public String dataName;
        public String dataCode;
        public String dataValue;
    }

    public class HDT_WRP_DocusignNotifyRadio{
        public String groupName;
        public String value;
        public String selected;
    }

    public class HDT_WRP_DocusignNotifyResponse{
        public String outcome;
        public String outcomeDescription;
    }
}
