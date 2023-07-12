public with sharing class HDT_SCH_ActivityDispatcherScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        HDT_BA_ActivityDispatcher executeBatch = new HDT_BA_ActivityDispatcher();
        BatchExecutionKpiConfiguration__mdt batchConfig = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_ActivityDispatcher');
        Database.executeBatch(executeBatch, (Integer) batchConfig.BatchSize__c);
    }
}
