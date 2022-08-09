public inherited sharing class HDT_QBL_SelfReadingsCallouts implements Queueable, Database.AllowsCallouts {
    
    private Case selfReadingsCase;
    private String requestType;
    private Boolean discardRework;

    public HDT_QBL_SelfReadingsCallouts(Case selfReadingsCase, String requestType) {
        this.selfReadingsCase = selfReadingsCase;
        this.requestType = requestType;
        this.discardRework = false;
    }

    public HDT_QBL_SelfReadingsCallouts(Case selfReadingsCase, String requestType,Boolean discardRework) {
        this(selfReadingsCase,requestType);
        this.discardRework = discardRework;
    }

    /*
    * @Author: Salvatore A. Sarà 20/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public void execute(QueueableContext context) {
        System.debug(LoggingLevel.DEBUG, 'HDT_QBL_SelfReadingsCallouts: request type: ' + this.requestType);

        if (String.isBlank(this.requestType)) {
            System.debug(LoggingLevel.DEBUG, 'HDT_QBL_SelfReadingsCallouts: nessuna requestType da processare');
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
        if (this.discardRework){
            args.put('discardRework', true);
        }
        args.put('parameters', parameters);
        HDT_SRV_SelfReadingsFacade facadeClass = new HDT_SRV_SelfReadingsFacade();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();

        if (this.requestType == 'InvioLettureForzato') {
            responseReturn = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) facadeClass.execute(args);
        }
    }
}
