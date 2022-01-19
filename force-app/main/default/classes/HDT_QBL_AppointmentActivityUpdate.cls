public with sharing class HDT_QBL_AppointmentActivityUpdate implements Queueable  {
    private List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
    private Boolean cloneActivty;

    public HDT_QBL_AppointmentActivityUpdate(List<wrts_prcgvr__Activity__c> activities) {
        this.activities = activities;
        this.cloneActivty = false;
    }

    public HDT_QBL_AppointmentActivityUpdate(wrts_prcgvr__Activity__c activity) {
        this.activities.add(activity);
        this.cloneActivty = false;
    }

    public HDT_QBL_AppointmentActivityUpdate(wrts_prcgvr__Activity__c activity,Boolean activtyToCloneInCreated) {
        this.activities.add(activity);
        this.cloneActivty = activtyToCloneInCreated;
    }

    public void execute(QueueableContext context) {
        if (this.cloneActivty){
            List<wrts_prcgvr__Activity__c> activitiesToInsert = new List<wrts_prcgvr__Activity__c>();
            for (wrts_prcgvr__Activity__c activity : this.activities){
                wrts_prcgvr__Activity__c activityToInsert = new wrts_prcgvr__Activity__c();
                activityToInsert.Order__c = activity.Order__c;
                activityToInsert.Case__c = activity.Case__c;
                activityToInsert.Distributor__c = activity.Distributor__c;
                activityToInsert.ServicePoint__c = activity.ServicePoint__c;
                activityToInsert.Account__c = activity.Account__c;
                activityToInsert.Contact__c = activity.Contact__c ;
                activityToInsert.isAtoa__c = activity.isAtoa__c;
                activityToInsert.RecordTypeid = activity.RecordTypeid;
                activityToInsert.wrts_prcgvr__Status__c = 'Creata';
                activitiesToInsert.add(activityToInsert);
            }
            if (!activitiesToInsert.isEmpty()){
                HDT_UTL_DatabaseService.insertSObject(activitiesToInsert);
            }
        }
            
        if(!this.activities.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(this.activities);
        }
    }
}