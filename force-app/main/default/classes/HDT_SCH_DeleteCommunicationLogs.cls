@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_SCH_DeleteCommunicationLogs implements Schedulable, Database.Stateful {
    
    global void execute(SchedulableContext ctx){
        HDT_BA_DeleteCommunicationLogs executeBatch = new HDT_BA_DeleteCommunicationLogs();
        BatchExecutionKpiConfiguration__mdt batchConfig = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_DeleteCommunicationLogs');
        Database.executeBatch(executeBatch, (Integer) batchConfig.BatchSize__c);
    }
}