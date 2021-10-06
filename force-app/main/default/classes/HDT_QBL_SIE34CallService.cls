public with sharing class HDT_QBL_SIE34CallService implements Queueable,Database.AllowsCallouts {
    String runId                    ;
    String status                   ;
    String fileType                 ;
    String errorMessage             ;
    List<String> contentVersionIds  ;

    public HDT_QBL_SIE34CallService(String runId,String status,String fileType,String errorMessage,List<String> contentVersionIds) {
        this.runId              = runId             ;
        this.status             = status            ;
        this.fileType           = fileType          ;
        this.errorMessage       = errorMessage      ;
        this.contentVersionIds  =contentVersionIds  ;
    }
    public void execute(QueueableContext context) {
        //System.debug('HDT_QBL_SIE34CallService.execute');
        HDT_WS_SIE34.callService(runId,status,fileType,errorMessage,contentVersionIds);
        
    }
}
