public inherited sharing class HDT_QBL_SelfReadingsCallouts implements Queueable, Database.AllowsCallouts {
    
    private Case selfReadingsCase;
    private String requestType;

    public HDT_QBL_SelfReadingsCallouts(Case selfReadingsCase, String requestType) {
        this.selfReadingsCase = selfReadingsCase;
        this.requestType = requestType;
    }

    public void execute(QueueableContext context) {
        System.debug('HDT_QBL_SelfReadingsCallouts: request type: ' + this.requestType);

        if (String.isBlank(this.requestType)) {
            System.debug('HDT_QBL_SelfReadingsCallouts: nessuna requestType da processare');
            return;
        }

        SObject transition;
        SObject action;
        Map<String, Object> args = new Map<String,Object>();
        Map<String, String> parameters = new Map<String,String>();
        parameters.put('requestType', this.requestType);

        // Case newCase = new Case();
        // newCase.Id = this.selfReadingsCase.Id;
        args.put('transition', transition);
        args.put('action', action);
        args.put('sender', this.selfReadingsCase);
        args.put('parameters', parameters);
        HDT_SRV_SelfReadingsFacade facadeClass = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();

        if (this.requestType == 'CheckAutolettura') {

            try {
                responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) facadeClass.execute(args);
                // Chiamiamo a cascata la prossima callout
                System.debug('HDT_QBL_SelfReadingsCallouts: chaining next job...');
                System.enqueueJob(new HDT_QBL_SelfReadingsCallouts(this.selfReadingsCase, 'InvioLetture'));

            } catch (Exception ex){
                System.debug('HDT_QBL_SelfReadingsCallouts: exception at line [' + ex.getLineNumber() + ']; ' + ex.getMessage());
            }

        } else if (this.requestType == 'InvioLetture') {
            responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) facadeClass.execute(args);
        }

        // ProcessClick non fa partire i job per le callout da contesto trigger o batch,
        // quindi demandiamo la callout heroku ad un platform event.
/*         System.debug('HDT_QBL_AnagAlignment: predisposizione platform event...');
        HDT_PEV_AnagAlignment__e event = new HDT_PEV_AnagAlignment__e();
        event.SerializedCase__c = JSON.serialize(anagAlignCase);

        Database.SaveResult sr = EventBus.publish(event);
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for (Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        } */
    }
}
