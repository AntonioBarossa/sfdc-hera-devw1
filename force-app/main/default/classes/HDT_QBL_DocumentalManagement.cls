public with sharing class HDT_QBL_DocumentalManagement implements Queueable {
    String recordId;
    String context;
    String params;
    public HDT_QBL_DocumentalManagement(String recordId,String context,String params) {
        this.params = params;
        this.recordId = recordId;
        this.context = context;
    }
    public void execute(System.QueueableContext qc) {
        /*CPQ: Il trigger puo' essere spento in quanto non si necessita di ricalcoli */
        HDT_UTL_QuoteProcess.disableCpq();
        HDT_SRV_DocumentalManagementFacade.sendDocument(recordId, context, params);
        HDT_UTL_QuoteProcess.enableCpq();
    }
}   
