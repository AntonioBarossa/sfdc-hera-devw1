public with sharing class HDT_QBL_InvioNumerazioni implements Queueable, Database.AllowsCallouts {
    private String macroactivity;
    private String phonenumber;
    private Datetime callDateTime;
    private String cmId;

    public HDT_QBL_InvioNumerazioni(String macroactivity, String phonenumber, Datetime callDateTime, String cmId) {
        this.macroactivity = macroactivity;
        this.phonenumber = phonenumber;
        this.callDateTime = callDateTime;
        this.cmId=cmId;
    }
    
    public void execute(QueueableContext context) {
        HDT_WS_Response response = HDT_WS_InvioNumerazioni.callService(this.macroactivity, this.phonenumber, this.callDateTime, this.cmId);
        System.debug(response);
    }
}
