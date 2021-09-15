public with sharing class HDT_WS_RicCreBpCaInvoker {
    public static HDT_WS_RichCreBpCaResponse invokeCall(HDT_WS_RicCreBpCaRequest req){
        HDT_WS_RichCreBpCaResponse res = (HDT_WS_RichCreBpCaResponse)HDT_WS_HTTPServiceCall.sendRequest('BP_CA' , req , HDT_WS_RichCreBpCaResponse.class);
       return res;
    }
}
