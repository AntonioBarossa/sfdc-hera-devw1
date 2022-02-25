public with sharing class HDT_WS_RicCreBpCaInvoker {
    private static final String REQUEST_PATH = '/customer-data/billing-profile';
    public static HDT_WS_RichCreBpCaResponse invokeCall(HDT_WS_RicCreBpCaRequest req){
        HDT_WS_RichCreBpCaResponse res = (HDT_WS_RichCreBpCaResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req , HDT_WS_RichCreBpCaResponse.class);
       return res;
    }
}
