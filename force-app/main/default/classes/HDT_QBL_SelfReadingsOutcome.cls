public inherited sharing class HDT_QBL_SelfReadingsOutcome implements Queueable, Database.AllowsCallouts {
    
    private List<Case> casesToUpdate;
    private List<wrts_prcgvr__Activity__c> activitiesToCreate;

    private static Integer MAX_CASES = 500;
    private static Integer MAX_ACTIVITIES = 500;

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

        List<Case> casesToProcess = new List<Case>();
        List<Case> casesToDelegate = new List<Case>();
        List<wrts_prcgvr__Activity__c> activitiesToProcess = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> activitiesToDelegate = new List<wrts_prcgvr__Activity__c>();

        for (Integer i = 0; i < this.casesToUpdate.size(); i++) {
            Case c = this.casesToUpdate[i];
            if (i < MAX_CASES) {
                casesToProcess.add(c);
            } else {
                casesToDelegate.add(c);
            }
        }

        for (Integer i = 0; i < this.activitiesToCreate.size(); i++) {
            wrts_prcgvr__Activity__c act = this.activitiesToCreate[i];
            if (i < MAX_ACTIVITIES) {
                activitiesToProcess.add(act);
            } else {
                activitiesToDelegate.add(act);
            }
        }

        // ProcessClick non fa partire i job per le callout da contesto queueable,
        // quindi demandiamo la DML che triggera la callout heroku ad un platform event.
        System.debug('HDT_QBL_SelfReadingsOutcome: setting up platform events...');
        List<HDT_PEV_SelfReading__e> events = new List<HDT_PEV_SelfReading__e>();

        for (Case c : casesToProcess) {
            HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
            event.SerializedCase__c = JSON.serialize(c);
            events.add(event);
        }

        for (wrts_prcgvr__Activity__c act : activitiesToProcess) {
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

        if (!casesToDelegate.isEmpty() || !activitiesToDelegate.isEmpty()) {
            System.debug('HDT_QBL_SelfReadingsOutcome: chaining next job...');
            System.enqueueJob(new HDT_QBL_SelfReadingsOutcome(casesToDelegate, activitiesToDelegate));
        }
    }
}
