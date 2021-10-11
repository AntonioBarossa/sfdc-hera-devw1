public inherited sharing class HDT_WRP_ProductAssociation {

    public class HDT_WRP_InsertResult {
        public Boolean success;
        public String message;
        public List<HDT_WRP_LineError> errorData;
    }

    public class HDT_WRP_LineError{
        @auraEnabled public String rowId;
        @auraEnabled public String errorMessage;
    }

    public class HDT_WRP_RespQueryObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String recordCounter;
        @AuraEnabled public List<Product2> prodList;
    }

    public class HDT_WRP_RespRunBatchObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }

    public class HDT_WRP_Notification {
        public String targetId;
        public Id userId;
        public String body;
        public String title; 
    }

}