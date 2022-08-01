public with sharing class HDT_TRH_AssignmentRule extends HDT_TRH_TriggerHandler {
    public override void beforeInsert() {
        HDT_UTL_AssignmentRule.handleQueues((List<AssignmentRule__c>) trigger.new);
    }
}
