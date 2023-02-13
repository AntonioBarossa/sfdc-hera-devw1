public with sharing class HDT_SCH_QualityCallScheduler implements Schedulable {
    public void execute(SchedulableContext ctx){
        HDT_BA_QualityCall batch = new HDT_BA_QualityCall();
        Database.executebatch(batch, HDT_UTL_QualityCall.ORDER_BATCH_SIZE);
    }
}
