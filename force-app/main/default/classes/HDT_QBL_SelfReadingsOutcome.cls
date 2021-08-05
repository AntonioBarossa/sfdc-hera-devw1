public inherited sharing class HDT_QBL_SelfReadingsOutcome implements Queueable, Database.AllowsCallouts {
    
    private List<Case> casesToUpdate;
    private List<wrts_prcgvr__Activity__c> activitiesToCreate;

    public HDT_QBL_SelfReadingsOutcome(List<Case> casesToUpdate, List<wrts_prcgvr__Activity__c> activitiesToCreate) {
        this.casesToUpdate = casesToUpdate != null ? casesToUpdate : new List<Case>();
        this.activitiesToCreate = activitiesToCreate != null ? activitiesToCreate : new List<wrts_prcgvr__Activity__c>();
    }

    public void execute(QueueableContext context) {
        System.debug('HDT_QBL_SelfReadingsOutcome start');
        System.debug('# cases to process: ' + this.casesToUpdate.size());
        System.debug('# activities to process: ' + this.activitiesToCreate.size());

        if (this.casesToUpdate.isEmpty() && this.activitiesToCreate.isEmpty()) {
            System.debug('Nothing to do.');
            return;
        }

        // ProcessClick non fa partire i job per le callout da contesto queueable,
        // quindi demandiamo la DML che triggera la callout heroku ad un platform event.
        System.debug('HDT_QBL_SelfReadingsOutcome: setting up platform events...');
        List<HDT_PEV_SelfReading__e> events = new List<HDT_PEV_SelfReading__e>();

        for (Case c : this.casesToUpdate) {
            HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
            event.SerializedCase__c = JSON.serialize(c);
            events.add(event);
        }

        for (wrts_prcgvr__Activity__c act : this.activitiesToCreate) {
            HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
            event.SerializedActivity__c = JSON.serialize(act);
            events.add(event);
        }

        if (!events.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(events);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
        }

/*         if (!nextJobCases.isEmpty()) {
            System.debug('HDT_QBL_SelfReadingsOutcome: chaining next job...');
            System.enqueueJob(new HDT_QBL_SelfReadingsOutcome(nextJobCases));
        } */
    }
}
