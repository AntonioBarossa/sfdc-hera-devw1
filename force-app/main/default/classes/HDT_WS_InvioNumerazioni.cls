public inherited sharing class HDT_WS_InvioNumerazioni {
    @AuraEnabled
    public static HDT_WS_Response callService(String macroactivity,String phonenumber){
        
        Map<String,String> req = new Map<String,String>();
        req.put('macroactivity', macroactivity);
        req.put('phonenumber', phonenumber);

        HDT_WS_Response res = HDT_WS_HTTPServiceCall.sendRequest('InvioNumerazioni', req, HDT_WS_Response.class);
        
        return res;
    }
}