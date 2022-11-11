public with sharing class HDT_SCH_PraxidiaFront implements Schedulable {
    public void execute(SchedulableContext ctx){
        HDT_BA_PraxidiaFront batch = new HDT_BA_PraxidiaFront();
        Database.executebatch(batch, 50);
    }
}