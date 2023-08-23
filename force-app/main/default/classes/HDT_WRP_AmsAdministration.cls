public with sharing class HDT_WRP_AmsAdministration {

    public class HDT_WRP_OperationResult{
        public String logId;
        public List<HDT_WRP_Result> results;

        public HDT_WRP_OperationResult(){
            results = new List<HDT_WRP_Result>();
            logId = '';
        }
    }

    public class HDT_WRP_Result { 
        public Boolean isSuccess;
        public String errorMessage;
        public String objectType;
        public String dmlOperation;
        public Id recordId;
    }

    public class HDT_WRP_Button{
        public String id;
        public String label;
        public Boolean isActive;
        public String className;
        public String method;
        public String status;
    }

}