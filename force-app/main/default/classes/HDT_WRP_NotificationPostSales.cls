public with sharing class HDT_WRP_NotificationPostSales {
    public class HDT_WRP_NotificationHeader{
        public String requestId;
        public String requestTimestamp;
        public String requestType;
        public List<HDT_WRP_NotificationField> fields;
    }
    
    public class HDT_WRP_NotificationField{
        public String fieldType;
        public String name;
        public String value;
    }
    
    public class HDT_WRP_NotificationObject{
        public List<HDT_WRP_NotificationField> fields;
        public String id;
        public String name;
        public List<HDT_WRP_NotificationObject> objects;
        public String objectType;
    }
    
    public class HDT_WRP_NotificationRequest{
        public HDT_WRP_NotificationHeader header;
        public List<HDT_WRP_NotificationObject> objects;
    }
    
    public class HDT_WRP_NotificationRoot{
        public HDT_WRP_NotificationHeader header;
        public List<HDT_WRP_NotificationRequest> requests;
    }
}