public inherited sharing class HDT_WS_InvioNumerazioni {
    private static final String REQUEST_PATH = '/campaigns/numbers'; 

    @AuraEnabled
    public static HDT_WS_Response callService(String macroactivity,String phonenumber){
        HDT_WS_InvioNumerazioniRequest r = new HDT_WS_InvioNumerazioniRequest();
        r.macroActivity = macroactivity;
        r.phoneNumber = phonenumber;
       /* Map<String,String> req = new Map<String,String>();
        req.put('macroactivity', macroactivity);
        req.put('phonenumber', phonenumber);*/

        HDT_WS_Response res = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', r, HDT_WS_Response.class);
        
        return res;
    }

    public class HDT_WS_InvioNumerazioniRequest extends HDT_WS_Request{
        @AuraEnabled Public String  macroActivity;
        @AuraEnabled Public String  phoneNumber;
       // @AuraEnabled Public String appointmentType;
       // @AuraEnabled Public String idUser;
       // @AuraEnabled Public String username;
      //  @AuraEnabled Public String ecid;
    }
}