public with sharing class HDT_WRP_SelfReadingsOutcome {

    public class HDT_WRP_SelfReadingsOutcomeRequest {
        public List<HDT_WRP_SelfReadingsOutcomeData> data;
    }

    public class HDT_WRP_SelfReadingsOutcomeData {
        public String caseId;
        public String errorCode;
        public String errorDescription;
        public String activityType;
    }

    public class HDT_WRP_SelfReadingsOutcomeResponse {
        public String outcome;
        public String outcomeDescription;
    }
}
