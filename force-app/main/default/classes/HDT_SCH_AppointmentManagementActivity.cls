public inherited sharing class HDT_SCH_AppointmentManagementActivity implements Schedulable {
    
    // Execute at regular intervals
    public void execute(SchedulableContext ctx){
        HDT_BA_AppoitmentManagmentActivity batch = new HDT_BA_AppoitmentManagmentActivity();
        Database.executebatch(batch, 200);
    }
}

