public with sharing class HDT_QBL_InvioNumerazioni implements Queueable {
    private String macroactivity;
    private String phonenumber;
    private Datetime callDateTime;

    public HDT_QBL_InvioNumerazioni(String macroactivity, String phonenumber, Datetime callDateTime) {
        this.macroactivity = macroactivity;
        this.phonenumber = phonenumber;
        this.callDateTime = callDateTime;
    }
    
    public void execute(QueueableContext context) {
        HDT_WS_Response response = HDT_WS_InvioNumerazioni.callService(this.macroactivity, this.phonenumber, this.callDateTime);
        System.debug(response);
    }
}
