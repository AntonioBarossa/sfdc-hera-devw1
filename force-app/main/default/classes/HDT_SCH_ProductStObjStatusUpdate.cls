public inherited sharing class HDT_SCH_ProductStObjStatusUpdate implements Schedulable {

    public void execute(SchedulableContext ctx){
        HDT_BA_ProductStObjStatusUpdate executeBatch = new HDT_BA_ProductStObjStatusUpdate();
        /*
            @Author: Davide Viola - 19/10/2021
            Description: PMD -> Commentata variabile non utilizzata.
        */
        /*Id batchId = */Database.executeBatch(executeBatch);
    }

}