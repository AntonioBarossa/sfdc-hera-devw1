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
                ArrearsOffice__c,
                ClientCategory__c,
                ClientMarking__c,
                Commodity__c,
                CompanyOwner__c,
                ComplaintSeverity__c,
                Distributor__c,
                HighPriorityQueue__c,
                LowPriorityQueue__c,
                MacroProcess__c,
                Market__c,
                MediumPriorityQueue__c,
                Priority__c,
                Process__c,
                QuoteType__c,
                SalesChannel__c,
                SubProcess__c,
                Type__c,
                Vendor__c
            FROM AssignmentRule__c
            WHERE
                RuleStartDate__c < TOMORROW AND RuleEndDate__c > TODAY
            ORDER BY RulePriority__c ASC
        ];
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<String,Map<String,Object>> queuesMap = getQueuesMap();
        List<AssignmentRule__c> rules = (List<AssignmentRule__c>) scope;
        List<wrts_prcgvr__Activity__c> processedActivities = new List<wrts_prcgvr__Activity__c>();
        Map<String,Object> queue;
        wrts_prcgvr__Activity__c tmp;
        
        for(AssignmentRule__c rule : rules) {
            for(wrts_prcgvr__Activity__c activity : Database.query(getQuery(rule))) {
                String assignataryQueue;
                switch on String.valueOf(activity.wrts_prcgvr__Priority__c) {
                    when '1' {
                        assignataryQueue = 'HighPriorityQueue__c';
                    }
                    when '2' {
                        assignataryQueue = 'MediumPriorityQueue__c';
                    }
                    when '3' {
                        assignataryQueue = 'LowPriorityQueue__c';
                    }
                }

                queue = queuesMap.get((String) rule.get(assignataryQueue));
                if((Integer) queue.get('DailyCapacity__c') > (Integer) queue.get('current_usage')) {
                    tmp = new wrts_prcgvr__Activity__c(
                        Id = activity.Id,
                        Queued__c = true,
                        AssignmentRule__c = rule.Id,
                        OwnerId = (String) queue.get('QueueId__c')
                    );
                    queue.put('current_usage', ((Integer) queue.get('current_usage')) + 1);
                    processedActivities.add(tmp);
                    if(processedActivities.size() == 10000) break;
                }
                if(processedActivities.size() == 10000) break;
            }
        }

        if(processedActivities.size() > 0) {
            Database.update(processedActivities, false);
        }
    }

    public void finish(Database.BatchableContext BC) {
        //RESCHEDULE
    }

    private Map<String,Map<String,Object>> getQueuesMap() {
        Map<String,Object> queueAsMap;
        Map<String,Map<String,Object>> queuesMap = new Map<String,Map<String,Object>>();
        for(Queue__c q : [SELECT Id, DailyCapacity__c, QueueId__c FROM Queue__c]) {
            queueAsMap = q.getPopulatedFieldsAsMap().clone();
            queueAsMap.put('current_usage', 0);
            queuesMap.put(q.Id, queueAsMap);
        }
        for(AggregateResult count : [SELECT COUNT(Id), OwnerId FROM wrts_prcgvr__Activity__c WHERE Owner.Type = 'Queue' GROUP BY OwnerId]) {
            queuesMap.get((String) count.get('OwnerId')).put('current_usage', count.get('expr0'));
        }
        return queuesMap;
    }

    public String getQuery(AssignmentRule__c rule) {
        Map<String,Object> ruleMap = rule.getPopulatedFieldsAsMap();
        // INITIALIZING QUERY'S STATIC PART
        List<String> query = new List<String> {'SELECT Id, wrts_prcgvr__Priority__c FROM wrts_prcgvr__Activity__c WHERE Queued__c = false'};
        String mapping;
        String value;
        String condition;
        // ADD EACH INDIVIDUAL WHERE CONDITION TO THE QUERY LIST
        for(String key : ruleMap.keySet()) {
            mapping = MAPPINGS.get(key);
            if(mapping != null) {
                value = '\'' + ((String) ruleMap.get(key)).replace(';','\',\'') + '\'';
                condition = mapping.replace(PLACEHOLDER, value);
                query.add(condition);
            }
        }
        // RETURN THE UNIFIED VALUES
        return String.join(query, ' AND ') + ' LIMIT 10000';
    }
}