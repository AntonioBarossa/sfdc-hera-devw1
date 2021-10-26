@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class HDT_SCH_PostSalesMasterBatch implements Schedulable, Database.AllowsCallouts{

    global void execute(SchedulableContext ctx){
        HDT_BA_PostSalesMasterBatch executeBatch = new HDT_BA_PostSalesMasterBatch();
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        /*Id batchId = */Database.executeBatch(executeBatch);
    }

}
