public inherited sharing class HDT_WRP_SlaManagement {

    public class HDT_WRP_Event {
        public Id recordId;
        public String sObjType;
        public String eventType;
        public Map<String, Object> fieldMap;
        public wrts_prcgvr__Activity__c activityEvent;
    }

    public class HDT_WRP_AdminRule {
        public Id adminRuleId;
        public Date startValidDate;
        public Date endValidDate;
        public Map<String, Object> objectCriteria;
        public HDT_WRP_RuleDetail startRule;
        public HDT_WRP_RuleDetail endRule;
        public String activityType;

        public HDT_WRP_AdminRule(){
            objectCriteria = new Map<String, Object>();
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