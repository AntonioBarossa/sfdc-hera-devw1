@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_QBL_AnagAlignment implements Queueable, Database.AllowsCallouts {
    private static HDT_QR_AnagAlignment anagAlignQr = new HDT_QR_AnagAlignment();
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
            HDT_WS_ArrichmentDataEntityResponse res = HDT_WS_ArrichmentDataEntityInvoker.callService(anagAlignCase.ContractCode__c, anagAlignCase.PODPDRFormula__c);
            HDT_UTL_DataEnrichmentPostSales.handleResponse(JSON.serialize(res), anagAlignCase);
            if(anagAlignCase.Excises__c == null && String.isNotBlank(anagAlignCase.Taxes__c))
            {
                List<HDT_ExciseTranscode__mdt> exciseTranscode = [SELECT Id, Excise__c FROM HDT_ExciseTranscode__mdt WHERE ExciseString__c = :anagAlignCase.Taxes__c];
                anagAlignCase.Excises__c = !exciseTranscode.isEmpty() ? exciseTranscode[0].Excise__c : 0.0;
            }
            if(anagAlignCase.RegionalAdditional__c == null && String.isNotBlank(anagAlignCase.Taxes__c))
            {
                anagAlignCase.RegionalAdditional__c = anagAlignQr.findRegionalAdditional(anagAlignCase.Taxes__c, anagAlignCase.SupplyCity__c, '');
            }
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