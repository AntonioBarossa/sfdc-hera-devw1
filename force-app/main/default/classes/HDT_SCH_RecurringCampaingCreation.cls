public inherited sharing class HDT_SCH_RecurringCampaingCreation implements Schedulable {  
    // Execute at regular intervals
    public void execute(SchedulableContext ctx){
        HDT_BA_RecurringCampaingCreation batch = new HDT_BA_RecurringCampaingCreation();
        Database.executebatch(batch,200);
    }
}