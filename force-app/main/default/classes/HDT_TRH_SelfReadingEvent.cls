public with sharing class HDT_TRH_SelfReadingEvent extends HDT_TRH_TriggerHandler {
    
    protected override void afterInsert() {
        System.debug('HDT_TRH_SelfReadingEvent trigger');
        List<Case> casesToUpdate = new List<Case>();
        List<wrts_prcgvr__Activity__c> activitiesToCreate = new List<wrts_prcgvr__Activity__c>();

        for (HDT_PEV_SelfReading__e event : (List<HDT_PEV_SelfReading__e>) Trigger.New) {

            if (String.isNotBlank(event.SerializedCase__c)) {
                Case selfReadingCase = (Case) JSON.deserialize(event.SerializedCase__c, Case.class);
                casesToUpdate.add(selfReadingCase);
            }

            if (String.isNotBlank(event.SerializedActivity__c)) {
                wrts_prcgvr__Activity__c activity = (wrts_prcgvr__Activity__c) JSON.deserialize(event.SerializedActivity__c, wrts_prcgvr__Activity__c.class);
                activitiesToCreate.add(activity);
            }
        }

        System.debug('# autoletture da aggiornare: ' + casesToUpdate.size());
        if (!casesToUpdate.isEmpty()) {
            HDT_UTL_DatabaseService.updateSObject(casesToUpdate);
        }

        System.debug('# attività di scarto da creare: ' + activitiesToCreate.size());
        if (!activitiesToCreate.isEmpty()) {
            HDT_UTL_DatabaseService.insertSObject(activitiesToCreate);
        }
    }
}