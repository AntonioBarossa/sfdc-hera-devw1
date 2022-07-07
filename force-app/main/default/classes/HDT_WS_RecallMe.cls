public with sharing class HDT_WS_RecallMe {
    private static final String RECALL_REQUEST_PATH = '/campaigns/slots/search';
    private static final String APPOINTMENT_REQUEST_PATH = '/campaigns/appointments';
    @AuraEnabled
    public static HDT_WS_RecallMeResponse postRecallMe(String nomeApi, HDT_WS_RecallMeRequest body) { 
		HDT_WS_RecallMeResponse res = (HDT_WS_RecallMeResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',RECALL_REQUEST_PATH,'POST', body, HDT_WS_RecallMeResponse.class);
        return res;
    }
    @AuraEnabled
    public static HDT_WS_Response postRecallMeAppointment(String nomeApi, HDT_WS_RecallMeConfirmRequest body) { 
		HDT_WS_Response res = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',APPOINTMENT_REQUEST_PATH,'POST', body, HDT_WS_Response.class);
        return res;
    }

    
}