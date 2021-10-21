public inherited sharing class HDT_QBL_SelfReadingsOutcome implements Queueable, Database.AllowsCallouts {
    
    private List<Case> casesToUpdate;
    private List<wrts_prcgvr__Activity__c> activitiesToCreate;
    private Map<Id,Boolean> isAutomaticDiscardMap;

    private static Integer maxCases = 500;
    private static Integer maxActivities = 500;
    private static Integer maxQueueableJobs = 50; // equivalente a Limits.getLimitQueueableJobs() da contesto sync. 


    public HDT_QBL_SelfReadingsOutcome(List<Case> casesToUpdate, List<wrts_prcgvr__Activity__c> activitiesToCreate, Map<Id,Boolean> isAutomaticDiscardMap) {
        this.casesToUpdate = casesToUpdate != null ? casesToUpdate : new List<Case>();
        this.activitiesToCreate = activitiesToCreate != null ? activitiesToCreate : new List<wrts_prcgvr__Activity__c>();
        this.isAutomaticDiscardMap = isAutomaticDiscardMap;
    }

    /*
    * @Author: Salvatore A. Sarà 20/10/2021
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void execute(QueueableContext context) {
        System.debug(LoggingLevel.DEBUG, '# cases in input: ' + this.casesToUpdate.size());
        System.debug(LoggingLevel.DEBUG,'# activities in input: ' + this.activitiesToCreate.size());

        if (this.casesToUpdate.isEmpty() && this.activitiesToCreate.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'Nothing to do.');
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
            System.debug(LoggingLevel.DEBUG, '# cases to update: ' + casesToProcess.size());
            HDT_UTL_DatabaseService.updateSObject(casesToProcess);
            // secondo update di fase per i Case che devono essere annullato a causa di scarto non lavorabile.
            List<Case> casesToDiscard = new List<Case>();
            for (Case c : casesToProcess) {
                if (this.isAutomaticDiscardMap.get(c.Id)) {
                    c.Phase__c = 'Annullato';
                    casesToDiscard.add(c);
                }
            }

            if (!casesToDiscard.isEmpty()) {
                HDT_UTL_DatabaseService.updateSObject(casesToDiscard);
            }
        }

        if (!activitiesToProcess.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, '# activities to create: ' + activitiesToProcess.size());
            HDT_UTL_DatabaseService.insertSObject(activitiesToProcess);
        }

        // ProcessClick non fa partire i job per le callout da contesto queueable,
        // quindi demandiamo la DML che triggera la callout heroku ad un platform event.
        if (!casesForHeroku.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'HDT_QBL_SelfReadingsOutcome: setting up platform event, # cases for heroku: ' + casesForHeroku.size());
            HDT_PEV_SelfReading__e event = new HDT_PEV_SelfReading__e();
            event.SerializedCases__c = JSON.serialize(casesForHeroku);

            Database.SaveResult sr = EventBus.publish(event);
            if (sr.isSuccess()) {
                System.debug(LoggingLevel.DEBUG, 'Successfully published event.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug(LoggingLevel.ERROR, 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        }

        if (!casesToDelegate.isEmpty() || !activitiesToDelegate.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'HDT_QBL_SelfReadingsOutcome: chaining next job...');
            System.enqueueJob(new HDT_QBL_SelfReadingsOutcome(casesToDelegate, activitiesToDelegate, this.isAutomaticDiscardMap));
        }
    }
}
