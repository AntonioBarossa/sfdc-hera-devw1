public inherited sharing class HDT_WS_InvioNumerazioni {
    private static final String CALLBACK_NOW = '/campaigns/numbers'; 
    private static final String CALLBACK_LATER = '/campaigns/calls-later'; 

    @AuraEnabled
    public static HDT_WS_Response callService(String macroactivity,String phonenumber, Datetime callDateTime){
        HDT_WS_InvioNumerazioniRequest request = new HDT_WS_InvioNumerazioniRequest();
        request.macroActivity = macroactivity;
        request.phoneNumber = phonenumber;

        HDT_WS_Response response;
        if(callDateTime == null) {
            // do CallMeBackNow
            response = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath', CALLBACK_NOW, 'POST', request, HDT_WS_Response.class);
        } else {
            // convert date to format: DD/MM/YYYY HH:mm
            request.callDateTime = String.valueOf(callDateTime).replaceAll('-', '/').left(16);
            // do CallMeBackLater
            response = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath', CALLBACK_LATER, 'POST', request, HDT_WS_Response.class);
        }
        
        return response;
    }

    @AuraEnabled
    public static HDT_WS_Response callService(String macroactivity,String phonenumber) {
        return callService(macroactivity, phonenumber, null);
    }

    public class HDT_WS_InvioNumerazioniRequest extends HDT_WS_Request{
        @AuraEnabled public String macroActivity;
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String callDateTime;
    }
}