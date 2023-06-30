public with sharing class HDT_SCH_UpdateActivitiesStatus implements Schedulable {
    public void execute(SchedulableContext ctx){
        HDT_BA_UpdateActivitiesStatus uaBatch = new HDT_BA_UpdateActivitiesStatus();
        BatchExecutionKpiConfiguration__mdt batchConfig = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_UpdateActivitiesStatus');
        Database.executeBatch(uaBatch, (Integer) batchConfig.BatchSize__c);
    }
}