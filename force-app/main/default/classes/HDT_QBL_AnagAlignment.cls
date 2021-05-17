public inherited sharing class HDT_QBL_AnagAlignment implements Queueable, Database.AllowsCallouts {
    
    private List<Case> anagAlignCases;

    public HDT_QBL_AnagAlignment(List<Case> anagAlignCases) {
        this.anagAlignCases = anagAlignCases;
    }

    public void execute(QueueableContext context) {
        System.debug('HDT_QBL_AnagAlignment: # case da processare: ' + this.anagAlignCases.size());

        if (this.anagAlignCases.isEmpty()) {
            System.debug('HDT_QBL_AnagAlignment: nessun Case da processare');
            return;
        }

        Case anagAlignCase = anagAlignCases[0];
        System.debug('HDT_QBL_AnagAlignment: arricchimento dati su Case: ' + anagAlignCase.Id);
        try {
            String arricchimentoResponse = HDT_WS_ArricchimentoDatiTemp.submitRequest(anagAlignCase.PODPDRFormula__c, anagAlignCase.ContractCode__c);
            HDT_UTL_DataEnrichmentPostSales.handleResponse(arricchimentoResponse, anagAlignCase);
        } catch (Exception ex){
            System.debug('HDT_QBL_AnagAlignment: arricchimento dati fallito: line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
        }

        List<Case> nextJobCases = new List<Case>();
        for (Integer i = 1; i < this.anagAlignCases.size(); i++) {
            nextJobCases.add(this.anagAlignCases[i]);
        }
        // Chain this job to next job by submitting the next job
        System.debug('HDT_QBL_AnagAlignment: chaining next job...');
        System.enqueueJob(new HDT_QBL_AnagAlignment(nextJobCases));

        // DML finale, va fatto dopo l'enqueuejob: https://medium.com/@CoachRWZ/salesforce-chaining-queueable-apex-callouts-53615b8dee92
        // Innesco invio ad Heroku.
        System.debug('HDT_QBL_AnagAlignment: predisposizione invio ad heroku per Case: ' + anagAlignCase.Id);
        anagAlignCase.Phase__c = 'Da Inviare';
        HDT_UTL_DatabaseService.updateSObject(anagAlignCase);
    }
}
