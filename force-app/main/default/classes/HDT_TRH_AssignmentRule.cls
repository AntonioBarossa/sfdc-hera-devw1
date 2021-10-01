public with sharing class HDT_TRH_AssignmentRule extends HDT_TRH_TriggerHandler {
    public override void beforeInsert(){
        populateUID((List<AssignmentRule__c>) trigger.new);
    }

    public override void beforeUpdate(){
        populateUID((List<AssignmentRule__c>) trigger.newMap.values());
    }

    private void populateUID(List<AssignmentRule__c> rules) {
        for(AssignmentRule__c rule : rules) {
            rule.UID__c = rule.RulePriority__c + rule.Type__c;
        }
    }
}