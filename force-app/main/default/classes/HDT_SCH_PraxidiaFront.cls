public with sharing class HDT_SCH_PraxidiaFront implements Schedulable {
    public string startTime;
    public string endTm;

    public HDT_SCH_PraxidiaFront(String start, String endTime){
        startTime=start; 
        endTm=endTime;
     }

    public void execute(SchedulableContext ctx){
        HDT_BA_PraxidiaFront batch = new HDT_BA_PraxidiaFront(startTime, endTm);
        Database.executebatch(batch, 100);
    }
}