public inherited sharing class HDT_SCH_LeadWebServiceReitekSend implements Schedulable {
    
    // Execute at regular intervals
    public void execute(SchedulableContext ctx){
        HDT_BA_LeadWebServiceReitekSend batch = new HDT_BA_LeadWebServiceReitekSend();
        Database.executebatch(batch, 1000);
    }
}





