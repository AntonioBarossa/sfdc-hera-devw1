public inherited sharing class HDT_SCH_ProductStObjStatusUpdate implements Schedulable {

    public void execute(SchedulableContext ctx){
        HDT_BA_ProductStObjStatusUpdate executeBatch = new HDT_BA_ProductStObjStatusUpdate();
        Id batchId = Database.executeBatch(executeBatch);
    }

}