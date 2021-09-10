public inherited sharing class HDT_QBL_SelfReadingsOutcome implements Queueable, Database.AllowsCallouts {
    
    private List<Case> casesToUpdate;
    private List<wrts_prcgvr__Activity__c> activitiesToCreate;

    private static Integer maxCases = 500;
    private static Integer maxActivities = 500;
    private static Integer maxQueueableJobs = 50; // equivalente a Limits.getLimitQueueableJobs() da contesto sync. 


    public HDT_QBL_SelfReadingsOutcome(List<Case> casesToUpdate, List<wrts_prcgvr__Activity__c> activitiesToCreate) {
        this.casesToUpdate = casesToUpdate != null ? casesToUpdate : new List<Case>();
        this.activitiesToCreate = activitiesToCreate != null ? activitiesToCreate : new List<wrts_prcgvr__Activity__c>();
    }

    public void execute(QueueableContext context) {
        System.debug('HDT_QBL_SelfReadingsOutcome start');
        System.debug('# cases in input: ' + this.casesToUpdate.size());
        System.debug('# activities in input: ' + this.activitiesToCreate.size());

        if (this.casesToUpdate.isEmpty() && this.activitiesToCreate.isEmpty()) {
            System.debug('Nothing to do.');
            return;
        }

        List<Case> casesToProcess = new List<Case>();
        List<Case> casesForHeroku = new List<Case>();
        List<Case> casesToDelegate = new List<Case>();
        List<wrts_prcgvr__Activity__c> activitiesToProcess = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> activitiesToDelegate = new List<wrts_prcgvr__Activity__c>();

        for (Integer i = 0; i < this.casesToUpdate.size(); i++) {
            Case c = this.casesToUpdate[i];
            if (i < maxCases) {
                if (c.Phase__c == 'Esito OK da SAP') {
                    if (casesForHeroku.size() < maxQueueableJobs - 1) {
                        casesForHeroku.add(c);
                    } else {
                        casesToDelegate.add(c);
                    }
                } else {
                    casesToProcess.add(c);
                }
            } else {
                casesToDelegate.add(c);
            }
        }

        for (Integer i = 0; i < this.activitiesToCreate.size(); i++) {
            wrts_prcgvr__Activity__c act = this.activitiesToCreate[i];
            if (i < maxActivities) {
                activitiesToProcess.add(act);
            } else {
                activitiesToDelegate.add(act);
            }
        }

        if (!casesToProcess.isEmpty()) {
            System.debug('# cases to update: ' + casesToProcess.size());
            HDT_UTL_DatabaseService.updateSObject(casesToProcess);
        }

        if (!activitiesToProcess.isEmpty()) {
            System.debug('# activities to create: ' + activitiesToProcess.size());
            HDT_UTL_DatabaseService.insertSObject(activitiesToProcess);
        }

        // ProcessClick non fa partire i job per le callout da contesto queueable,
        // quindi demandiamo la DML che triggera la callout heroku ad un platform event.
        if (!casesForHeroku.isEmpty()) {
            System.debug('HDT_QBL_SelfReadingsOutcome: setting up platform event, # cases for heroku: ' + casesForHeroku.size());
            HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
            event.SerializedCases__c = JSON.serialize(casesForHeroku);

            Database.SaveResult sr = EventBus.publish(event);
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }

        if (!casesToDelegate.isEmpty() || !activitiesToDelegate.isEmpty()) {
            System.debug('HDT_QBL_SelfReadingsOutcome: chaining next job...');
            System.enqueueJob(new HDT_QBL_SelfReadingsOutcome(casesToDelegate, activitiesToDelegate));
        }
    }
}
