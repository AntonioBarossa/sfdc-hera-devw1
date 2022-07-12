public with sharing class HDT_UTL_AssignmentRule {
    public static void handleQueues(List<AssignmentRule__c> rules) {
        Map<String,Id> queueNamesToIds = new Map<String,Id>();
        for(Queue__c wrapper : [SELECT Id, Name FROM Queue__c WITH SECURITY_ENFORCED]) {
            queueNamesToIds.put(wrapper.Name, wrapper.Id);
        }

        for(AssignmentRule__c rule : rules) {
            if(rule.HighPriorityQueueImport__c != null && rule.LowPriorityQueueImport__c != null && rule.MediumPriorityQueueImport__c != null) {
                rule.HighPriorityQueue__c = queueNamesToIds.get(rule.HighPriorityQueueImport__c);
                rule.MediumPriorityQueue__c = queueNamesToIds.get(rule.MediumPriorityQueueImport__c);
                rule.LowPriorityQueue__c = queueNamesToIds.get(rule.LowPriorityQueueImport__c);
            }
        }
    }
}
