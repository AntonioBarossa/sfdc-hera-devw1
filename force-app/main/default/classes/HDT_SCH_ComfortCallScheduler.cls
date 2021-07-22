public with sharing class HDT_SCH_ComfortCallScheduler implements Schedulable {
    
    public void execute(SchedulableContext ctx){
        HDT_BA_ComfortCall batch = new HDT_BA_ComfortCall();
        Database.executebatch(batch, 200);
    }
}
