public with sharing class HDT_SCH_ActivityGestionManualeScheduler implements Schedulable {

    public static String batchName = 'Gestione Manuale SAP Batch';

    public void execute(SchedulableContext context) {
        Database.executeBatch(new HDT_BA_ActivityGestionManuale());
    }

    public static void scheduleMe(String cron){
        HDT_SCH_ActivityGestionManualeScheduler activityScheduler = new HDT_SCH_ActivityGestionManualeScheduler();
        System.schedule(batchName, cron , activityScheduler);
    }
}
