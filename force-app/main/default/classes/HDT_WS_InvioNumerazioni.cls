public inherited sharing class HDT_WS_InvioNumerazioni {
    private static final String CALLBACK_NOW = '/campaigns/numbers'; 
    private static final String CALLBACK_LATER = '/campaigns/calls-later'; 

    @AuraEnabled
    public static HDT_WS_Response callService(String macroactivity,String phonenumber, Datetime callDateTime, String cmId, String agency){
        HDT_WS_InvioNumerazioniRequest request = new HDT_WS_InvioNumerazioniRequest();
        request.macroActivity = macroactivity;
        request.phoneNumber = phonenumber;
        request.callcenterName=agency;
        request.queueName='PREVIEW';
        HDT_WS_StructureData structData=new HDT_WS_StructureData();
        structData.campaignMemberId=cmId;
        request.structureData=structData;
        system.debug('Krist: '+ json.serialize(request) );
        HDT_WS_Response response;
        if(callDateTime == null) {
            // do CallMeBackNow
            response = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath', CALLBACK_NOW, 'POST', request, HDT_WS_Response.class);
        } else {
            // convert date to format: YYYY/MM/DD HH:mm
            request.callDateTime = String.valueOf(callDateTime.format('yyyy/MM/dd hh:mm'));
            // do CallMeBackLater
            System.debug('request pre CallMeBackLater: '+request);
            response = HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath', CALLBACK_LATER, 'POST', request, HDT_WS_Response.class);
        }
        
        return response;
    }

    @AuraEnabled
    public static HDT_WS_Response callService(String macroactivity,String phonenumber, String cmId, String agency) {
        return callService(macroactivity, phonenumber, null, cmId, agency);
    }

    public static HDT_WS_Response callService(String macroactivity,String phonenumber, Datetime callDateTime, String cmId) {
        // force deploy
        return new HDT_WS_Response();
    }


    public class HDT_WS_InvioNumerazioniRequest extends HDT_WS_Request{
        @AuraEnabled public String macroActivity;
        @AuraEnabled public String phoneNumber;
        @AuraEnabled public String callDateTime;
        @AuraEnabled public String callcenterName;
        @AuraEnabled public String queueName;

        @AuraEnabled public HDT_WS_StructureData structureData=new HDT_WS_StructureData();
    }

    public class HDT_WS_StructureData{
        @AuraEnabled public String campaignMemberId;
    }
}