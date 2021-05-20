public with sharing class HDT_BA_ActivityDispatcher implements Database.Batchable<sObject> {
    private static final String PLACEHOLDER = '###';
    private static final Map<String,String> MAPPINGS = new Map<String,String> {
        'SAPStep__c' => 'SAPStep__c IN (###)',
        'Type__c' => 'Type__c IN (###)',
        'Priority__c' => 'wrts_prcgvr__Priority__c IN (###)',
        'CompanyOwner__c' => 'Account__r.CompanyOwner__c IN (###)',
        'ClientCategory__c' => 'Account__r.Category__c IN (###)',
        'ClientMarking__c' => 'Account__r.CustomerMarking__c IN (###)',
        'ComplaintSeverity__c' => 'Case__r.CriticalAttribute__c IN (###)',
        'QuoteType__c' => 'Case__r.QuotationType__c IN (###)',
        'ArrearsOffice__c' => 'Case__r.CompetentOffice__c IN (###)',
        'UserCreatorChannel__c' => 'Case__r.Origin IN (###)',
        'BPCode__c' => 'Account__r.CustomerCode__c IN (###)',
        'Segment__c' => 'Account__r.Segment__c IN (###)',
        'SAPStep__c' => 'SAPStep__c IN (###)',
        'FirstLevelOpinion__c' => 'Case__r.FirstLevelOpinion__c IN (###)',
        'SecondLevelOpinion__c' => 'Case__r.SecondLevelOpinion__c IN (###)',
        'UserCreatorAgency__c' => 'Order__r.CreatedBy.UserCompany__c IN (###)',
        'UserCreatorGroup__c' => 'Order__r.CreatedBy.CreatorGroup__c IN (###)',
        'SalesChannel__c' => 'Order__r.Channel__c IN (###)',
        'OfferType__c' => 'Order__r.OfferType__c IN (###)',
        'SalesChannel__c' => 'Order__r.Sale__r.Channel__c IN (###)',
        'Distributor__c' => '(Case__r.DistributorName__c IN (###) OR Order__r.DistributorFormula__c IN (###))',
        'Market__c' => '(Case__r.Market__c IN (###) OR Order__r.Market__c IN (###))',
        'Vendor__c' => '(Case__r.SalesCompany__c IN (###) OR Order__r.SalesCompany__c IN (###))',
        'MacroProcess__c' => '(Case__r.Cluster__c IN (###) OR Order__r.Cluster__c IN (###))',
        'Process__c' => '(Case__r.ProcessType__c IN (###) OR Order__r.ProcessType__c IN (###))',
        'SubProcess__c' => '(Case__r.SubProcess__c IN (###) OR Order__r.Subprocess__c IN (###))',
        'Commodity__c' => '(Case__r.Commodity__c IN (###) OR Order__r.CommodityFormula__c IN (###))'
    };

    public List<AssignmentRule__c> start(Database.BatchableContext BC) {
        return [
            SELECT
                Id,
                Queue__c,
                RulePriority__c,
                RuleStartDate__c,
                RuleEndDate__c,
                Type__c,
                Priority__c,
                CompanyOwner__c,
                ClientCategory__c,
                ClientMarking__c,
                Market__c,
                Vendor__c,
                MacroProcess__c,
                Process__c,
                SubProcess__c,
                Commodity__c,
                ComplaintSeverity__c,
                QuoteType__c,
                ArrearsOffice__c,
                SalesChannel__c,
                Distributor__c
            FROM AssignmentRule__c
            WHERE
                RuleStartDate__c < TOMORROW AND RuleEndDate__c > TODAY
            ORDER BY RulePriority__c ASC
        ];
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Queue__c> queues = [
            SELECT
                Id,
                Name,
                QueueId__c,
                Agency__c,
                DailyCapacity__c,
                Group__c,
                Priority__c,
                Type__c
            FROM Queue__c
        ];

        List<AssignmentRule__c> rules = (List<AssignmentRule__c>) scope;
        List<wrts_prcgvr__Activity__c> processedActivities = new List<wrts_prcgvr__Activity__c>();
        String query;

        for(AssignmentRule__c rule : rules) {
            for(wrts_prcgvr__Activity__c activity : Database.query(query)) {
                activity.Queued__c = true;
                processedActivities.add(activity);
            }
        }
        Database.update(processedActivities, false);
    }

    public void finish(Database.BatchableContext BC) {
        //RESCHEDULE
    }

    public String getQuery(AssignmentRule__c rule) {
        Map<String,Object> ruleMap = rule.getPopulatedFieldsAsMap();
        // REMOVING NON-MAPPED FIELDS
        ruleMap.remove('Id');
        ruleMap.remove('Name');
        ruleMap.remove('RulePriority__c');
        ruleMap.remove('RuleStartDate__c');
        ruleMap.remove('RuleEndDate__c');
        ruleMap.remove('Queue__c');
        // INITIALIZING QUERY'S STATIC PART
        List<String> query = new List<String> {'SELECT Id FROM wrts_prcgvr__Activity__c WHERE Queued__c = false'};
        String mapping;
        String value;
        String condition;
        // ADD EACH INDIVIDUAL WHERE CONDITION TO THE QUERY LIST
        for(String key : ruleMap.keySet()) {
            mapping = MAPPINGS.get(key);
            value = (String) ruleMap.get(key);
            condition = mapping.replace(PLACEHOLDER, value.replace(';',','));
            query.add(condition);
        }
        // RETURN THE UNIFIED VALUES
        return String.join(query, ' AND ');
    }
}