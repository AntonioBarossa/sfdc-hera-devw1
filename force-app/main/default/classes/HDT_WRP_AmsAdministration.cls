public with sharing class HDT_WRP_AmsAdministration {

    public class HDT_WRP_OperationResult{
        public List<HDT_WRP_Result> results;

        public HDT_WRP_OperationResult(){
            results = new List<HDT_WRP_Result>();
        }
    }

    public class HDT_WRP_Result { 
        public Boolean isSuccess;
        public String errorMessage;
        public String objectType;
        public Id recordId;
    }

}