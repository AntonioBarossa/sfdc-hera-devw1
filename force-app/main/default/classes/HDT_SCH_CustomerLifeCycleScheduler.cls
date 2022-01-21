public with sharing class HDT_SCH_CustomerLifeCycleScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        Database.executeBatch(new HDT_BA_CustomerLifeCycle(), 1000);
    }
}
