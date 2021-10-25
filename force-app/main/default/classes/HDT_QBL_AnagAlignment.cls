@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_QBL_AnagAlignment implements Queueable, Database.AllowsCallouts {
    
    private List<Case> anagAlignCases;

    public HDT_QBL_AnagAlignment(List<Case> anagAlignCases) {
        this.anagAlignCases = anagAlignCases;
    }

    public void execute(QueueableContext context) {
        System.debug(LoggingLevel.DEBUG, 'HDT_QBL_AnagAlignment: # case da processare: ' + this.anagAlignCases.size());

        if (this.anagAlignCases.isEmpty()) {
            System.debug(LoggingLevel.DEBUG, 'HDT_QBL_AnagAlignment: nessun Case da processare');
            return;
        }

        Case anagAlignCase = anagAlignCases[0];
        System.debug(LoggingLevel.DEBUG, 'HDT_QBL_AnagAlignment: arricchimento dati...');
        try {
            String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(anagAlignCase.PODPDRFormula__c, anagAlignCase.ContractCode__c);
            HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, anagAlignCase);
        } catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, 'HDT_QBL_AnagAlignment: arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
        }

        List<Case> nextJobCases = new List<Case>();
        for (Integer i = 1; i < this.anagAlignCases.size(); i++) {
            nextJobCases.add(this.anagAlignCases[i]);
        }

        if (!nextJobCases.isEmpty()) {
            // Chain this job to next job by submitting the next job
            System.debug(LoggingLevel.DEBUG, 'HDT_QBL_AnagAlignment: chaining next job...');
            if(!Test.isRunningTest()) {
                System.enqueueJob(new HDT_QBL_AnagAlignment(nextJobCases));
            }
        }

        // ProcessClick non fa partire i job per le callout da contesto trigger o batch,
        // quindi demandiamo la callout heroku ad un platform event.
        System.debug(LoggingLevel.DEBUG, 'HDT_QBL_AnagAlignment: predisposizione platform event...');
        HDT_PEV_AnagAlignment__e event = new HDT_PEV_AnagAlignment__e();
        event.SerializedCase__c = JSON.serialize(anagAlignCase);

        Database.SaveResult sr = EventBus.publish(event);
        if (sr.isSuccess()) {
            System.debug(LoggingLevel.DEBUG, 'Successfully published event.');
        } else {
            for (Database.Error err : sr.getErrors()) {
                System.debug(LoggingLevel.DEBUG, 'Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }
    }
}
