public inherited sharing class HDT_SCH_LeadExpiredScheduler implements Schedulable {
    
        // Execute at regular intervals
        public void execute(SchedulableContext ctx){
            HDT_BA_LeadExpired batch = new HDT_BA_LeadExpired();
            Database.executebatch(batch, 200);
        }
}
