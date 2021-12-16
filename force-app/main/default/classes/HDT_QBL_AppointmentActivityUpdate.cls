public with sharing class HDT_QBL_AppointmentActivityUpdate implements Queueable  {
    private wrts_prcgvr__Activity__c activity;
    private Boolean cloneActivty;

    public HDT_QBL_AppointmentActivityUpdate(wrts_prcgvr__Activity__c activity) {
        this.activity = activity;
        this.cloneActivty = false;
    }

    public HDT_QBL_AppointmentActivityUpdate(wrts_prcgvr__Activity__c activity,Boolean activtyToCloneInCreated) {
        this.activity = activity;
        this.cloneActivty = activtyToCloneInCreated;
    }

    public void execute(QueueableContext context) {
        if (this.cloneActivty){
            wrts_prcgvr__Activity__c activityToInsert = new wrts_prcgvr__Activity__c();
            activityToInsert.Order__c = this.activity.Order__c;
            activityToInsert.Case__c = this.activity.Case__c;
            activityToInsert.Distributor__c = this.activity.Distributor__c;
            activityToInsert.ServicePoint__c = this.activity.ServicePoint__c;
            activityToInsert.Account__c = this.activity.Account__c;
            activityToInsert.Contact__c = this.activity.Contact__c ;
            activityToInsert.isAtoa__c = this.activity.isAtoa__c;
            activityToInsert.RecordTypeid = this.activity.RecordTypeid;
            activityToInsert.wrts_prcgvr__Status__c = 'Creata';
            HDT_UTL_DatabaseService.insertSObject(activityToInsert);
        }
            
        if(this.activity != null){
            HDT_UTL_AppointmentAgenda.updateActivity(this.activity);
        }
    }
}