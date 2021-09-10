public inherited sharing class HDT_SCH_SuspendedActivities implements Schedulable {
    public void execute(SchedulableContext ctx){
        HDT_BA_SuspendedActivitiesEmailAlert batch = new HDT_BA_SuspendedActivitiesEmailAlert();
        Database.executebatch(batch,100);
    }
}
