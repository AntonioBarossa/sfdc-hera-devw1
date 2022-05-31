global with sharing class HDT_SCH_CommercialCode implements Schedulable{
    global void execute(SchedulableContext sc) {
        HDT_BA_CommercialCode ccBatch = new HDT_BA_CommercialCode();
        Database.executeBatch(ccBatch, 200);
    }
}