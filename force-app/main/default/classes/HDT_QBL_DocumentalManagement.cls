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
        HDT_SRV_DocumentalManagementFacade.sendDocument(recordId, context, params);
    }
}   
