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
        'FirstLevelOpinion__c' => 'Case__r.FirstLevelOpinion__c IN (###)',
        'SecondLevelOpinion__c' => 'Case__r.SecondLevelOpinion__c IN (###)',
        'CreatorAgency__c' => 'Order__r.CreatedBy.UserCompany__c IN (###)',
        'UserCreatorGroup__c' => 'Order__r.CreatedBy.CreatorGroup__c IN (###)',
        'SalesChannel__c' => 'Order__r.Channel__c IN (###)',
        'OfferType__c' => 'Order__r.OfferType__c IN (###)',
        'Distributor__c' => '(Case__r.DistributorName__c IN (###) OR Order__r.DistributorFormula__c IN (###))',
        'Market__c' => '(Case__r.Market__c IN (###) OR Order__r.Market__c IN (###))',
        'Vendor__c' => '(Case__r.SalesCompany__c IN (###) OR Order__r.SalesCompany__c IN (###))',
        // 'SalesAgency__c' => 'Order__r.Agency__c IN (###)',
        'MacroProcess__c' => '(Case__r.Cluster__c IN (###) OR Order__r.Cluster__c IN (###))',
        'Process__c' => '(Case__r.Type IN (###) OR Order__r.ProcessType__c IN (###))',
        'SubProcess__c' => '(Case__r.SubProcess__c IN (###) OR Order__r.Subprocess__c IN (###))',
        'Commodity__c' => '(Case__r.Commodity__c IN (###) OR Order__r.CommodityFormula__c IN (###))'
    };

    public List<AssignmentRule__c> start(Database.BatchableContext bc) {
        return [
            SELECT
                Id,
                Type__c,
                BPCode__c,
                ArrearsOffice__c,
                Segment__c,
                Distributor__c,
                SAPStep__c,
                QuoteType__c,
                SalesChannel__c,
                SalesAgency__c,
                CompanyOwner__c,
                MacroProcess__c,
                Process__c,
                Subprocess__c,
                Priority__c,
                ClientMarking__c,
                ClientCategory__c,
                Commodity__c,
                ComplaintSeverity__c,
                Market__c,
                UserCreatorChannel__c,
                CreatorAgency__c,
                UserCreatorGroup__c,
                OfferType__c,
                FirstLevelOpinion__c,
                SecondLevelOpinion__c,
                Vendor__c,
                SupplyType__c,
                HighPriorityQueue__c,
                MediumPriorityQueue__c,
                LowPriorityQueue__c
            FROM AssignmentRule__c
            WHERE
                Deactivated__c = false AND
                (RuleStartDate__c <= :Datetime.now() OR RuleStartDate__c = null) AND
                (RuleEndDate__c > :Datetime.now() OR RuleEndDate__c = null)
            ORDER BY RulePriority__c ASC
        ];
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<AssignmentRule__c> rules = (List<AssignmentRule__c>) scope;

        Map<String,Queue__c> queuesMap = getQueuesMap();
        Map<String,Decimal> queueUsageMap = getQueueUsageMap();

        Queue__c queue;
        wrts_prcgvr__Activity__c processedActivity;
        Decimal queueUsage;
        Map<Id, wrts_prcgvr__Activity__c> processedActivitiesMap = new Map<Id, wrts_prcgvr__Activity__c>();
        String assignataryQueue;

        for(AssignmentRule__c rule : rules) {
            for(wrts_prcgvr__Activity__c activity : Database.query(getQuery(rule))) {
                
                //IF ACTIVITY ALREADY ASSIGNED BY ANOTHER, HIGHER PRIORITY RULE IN THE SAME BATCH DO NOT RE-PROCESS
                if(processedActivitiesMap.containsKey(activity.Id)){
                    continue;
                }

                assignataryQueue = null;
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
                queueUsage = queueUsageMap.get(queue.QueueId__c);
                if(queueUsage == null){
                    queueUsage = 0;
                }

                if(queue.DailyCapacity__c == null || queue.DailyCapacity__c > queueUsage) {
                    processedActivity = new wrts_prcgvr__Activity__c(
                        Id = activity.Id,
                        Queued__c = true,
                        AssignmentRule__c = rule.Id,
                        Agency__c = queue.Agency__c,
                        WorkGroup__c = queue.Group__c,
                        AssigneeType__c = 'Coda',
                        Queue__c = queue.Id,
                        RuleChosenQueue__c = queue.Id,
                        OwnerId = (Id) queue.QueueId__c
                    );
                    if(queue.DailyCapacity__c != null) {
                        queueUsageMap.put(queue.QueueId__c, ++queueUsage);
                    }
                    processedActivitiesMap.put(processedActivity.Id, processedActivity);
                }
                
                // IF MAXIMUM SIZE FOR DML ACTION REACHED STOP PROCESSING
                if(processedActivitiesMap.size() == 10000){
                    break;
                }
            }
        }

        if(!processedActivitiesMap.isEmpty()) {
            List<Database.SaveResult> results = Database.update(processedActivitiesMap.values(), false);

            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    System.debug(result.getId() + ' | ' + result.getErrors());
                }
            }
        }
    }

    //NB: risolto merge conflict durante cleanup PMD
    public void finish(Database.BatchableContext bc) {
        //RESCHEDULE
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug('HDT_BA_ActivityDispatcher - finished job: ' + a);
        
    }

    private Map<String,Queue__c> getQueuesMap() {
        return new Map<String,Queue__c>([SELECT Id, DailyCapacity__c, Agency__c, Group__c, QueueId__c FROM Queue__c]);
    }
    
    private Map<String,Decimal> getQueueUsageMap() {
        Map<String,Decimal> queueUsageMap = new Map<String,Decimal>();
        for(AggregateResult count : [SELECT COUNT(Id), OwnerId FROM wrts_prcgvr__Activity__c WHERE Owner.Type = 'Queue' GROUP BY OwnerId]) {
            queueUsageMap.put((String) count.get('OwnerId'), (Decimal) count.get('expr0'));
        }
        return queueUsageMap;
    }

    public String getQuery(AssignmentRule__c rule) {
        Map<String,Object> ruleMap = rule.getPopulatedFieldsAsMap();
        // INITIALIZING QUERY'S STATIC PART
        List<String> query = new List<String> {'SELECT Id, wrts_prcgvr__Priority__c FROM wrts_prcgvr__Activity__c WHERE Queued__c = false AND ManuallyReassigned__c = false AND wrts_prcgvr__Priority__c != null AND wrts_prcgvr__Status__c IN (\'Not Started\', \'Aperta\')'};
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