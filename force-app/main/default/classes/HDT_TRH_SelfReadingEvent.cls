public with sharing class HDT_TRH_SelfReadingEvent extends HDT_TRH_TriggerHandler {
    
    protected override void afterInsert() {
        System.debug('HDT_TRH_SelfReadingEvent trigger');
        List<Case> casesToUpdate = new List<Case>();

        List<HDT_PEV_SelfReading__e> events = (List<HDT_PEV_SelfReading__e>) Trigger.New;
        System.debug('# events: ' + events.size());
        System.debug('max jobs: ' + Limits.getLimitQueueableJobs());

        for (HDT_PEV_SelfReading__e event : events) {

            if (String.isNotBlank(event.SerializedCase__c)) {
                Case selfReadingCase = (Case) JSON.deserialize(event.SerializedCase__c, Case.class);
                casesToUpdate.add(selfReadingCase);
            }

            if (String.isNotBlank(event.SerializedCases__c)) {
                List<Case> selfReadingCases = (List<Case>) JSON.deserialize(event.SerializedCases__c, List<Case>.class);
                casesToUpdate.addAll(selfReadingCases);
            }
        }

        System.debug('# autoletture da aggiornare: ' + casesToUpdate.size());
        System.debug('# Limits - Limit Queueable Jobs: ' + Limits.getLimitQueueableJobs());

        List<Case> casesToProcess = new List<Case>();
        List<Case> casesToDelegate = new List<Case>();

        // Possiamo aggiornare solo 50 Case, altrimento sforiamo il limite di queueable jobs per questa transazione.
        for (Integer i = 0; i < casesToUpdate.size(); i++) {
            Case c = casesToUpdate[i];
            if (i < Limits.getLimitQueueableJobs() - 1) {
                casesToProcess.add(c);
            } else {
                casesToDelegate.add(c);
            }
        }

        if (!casesToProcess.isEmpty()) {
            System.debug('# case da aggiornare: ' + casesToProcess.size());
            HDT_UTL_DatabaseService.updateSObject(casesToProcess);
        }

        // I restanti Case li deleghiamo ad un altro platform event. 
        if (!casesToDelegate.isEmpty()) {
            System.debug('# case da delegare ad un altro evento: ' + casesToDelegate.size());
            HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
            event.SerializedCases__c = JSON.serialize(casesToDelegate);

            Database.SaveResult sr = EventBus.publish(event);
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }
    }

}