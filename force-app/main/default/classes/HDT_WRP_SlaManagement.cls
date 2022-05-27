public inherited sharing class HDT_WRP_SlaManagement {

    public class HDT_WRP_sObject {
        public Id recordId;
        public String sObjType;
        public String eventType;
        public Map<String, Object> fieldMap;    
    }

    public class HDT_WRP_SlaAdmin {
        public Id slaAdminId;
        public HDT_WRP_RuleDetail startRule;
        public HDT_WRP_RuleDetail endRule;

        public HDT_WRP_SlaAdmin(){
            startRule = new HDT_WRP_RuleDetail();
            endRule = new HDT_WRP_RuleDetail();
        }
        
    }

    public class HDT_WRP_RuleDetail {
        public Boolean isDate;
        public String obj;
        public String field;
        public String value;
    }

}