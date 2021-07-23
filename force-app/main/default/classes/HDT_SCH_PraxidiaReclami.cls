public with sharing class HDT_SCH_PraxidiaReclami implements Schedulable {
    public void execute(SchedulableContext ctx){
        HDT_BA_PraxidiaReclami batch = new HDT_BA_PraxidiaReclami();
        Database.executebatch(batch, 200);
    }
}