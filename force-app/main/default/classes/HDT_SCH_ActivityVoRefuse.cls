public with sharing class  HDT_SCH_ActivityVoRefuse implements Schedulable {

    public void execute(SchedulableContext sc) {
        HDT_BA_ActivityVoRefuse oldDraftSales = new HDT_BA_ActivityVoRefuse();
        Database.executeBatch(oldDraftSales);
    }
}
