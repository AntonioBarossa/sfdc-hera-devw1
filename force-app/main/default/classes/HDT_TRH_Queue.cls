public with sharing class HDT_TRH_Queue extends HDT_TRH_TriggerHandler {
    public override void afterInsert() {
        HDT_UTL_Queue.createUnderlyingQueue((List<Queue__c>) trigger.new);
    }
}