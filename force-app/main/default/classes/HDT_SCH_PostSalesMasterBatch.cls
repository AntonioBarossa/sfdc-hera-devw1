global inherited sharing class HDT_SCH_PostSalesMasterBatch implements Schedulable{

    global void execute(SchedulableContext ctx){
        HDT_BA_PostSalesMasterBatch executeBatch = new HDT_BA_PostSalesMasterBatch();
        Id batchId = Database.executeBatch(executeBatch);
    }

}
