public with sharing class HDT_SCH_ActivityDispatcherScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        Database.executeBatch(new HDT_BA_ActivityDispatcher(), 150);
    }
}
