@SuppressWarnings('PMD.AvoidDebugStatements')
public without sharing class HDT_TRH_AppointmentAgendaEvent extends HDT_TRH_TriggerHandler{
    
    protected override void afterInsert() {
        System.debug(LoggingLevel.DEBUG, 'HDT_TRH_AppointmentAgendaEvent trigger');
        List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
        for (HDT_PEV_AppointmentAgenda__e appEvent : (List<HDT_PEV_AppointmentAgenda__e>)Trigger.new){
            wrts_prcgvr__Activity__c activity = (wrts_prcgvr__Activity__c) JSON.deserialize(appEvent.Activity_JSON__c,wrts_prcgvr__Activity__c.class);
            activities.add(activity);
        }
        System.debug(LoggingLevel.DEBUG, 'Aggiornamento Campi Attività');
        HDT_UTL_DatabaseService.updateSObject(activities);
    }

}