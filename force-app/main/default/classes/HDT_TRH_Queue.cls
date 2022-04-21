public with sharing class HDT_TRH_Queue extends HDT_TRH_TriggerHandler {
    public override void afterInsert() {
        System.enqueueJob(new HDT_QBL_CreateQueuesAndGroups((List<Queue__c>) trigger.new, false));
    }
}