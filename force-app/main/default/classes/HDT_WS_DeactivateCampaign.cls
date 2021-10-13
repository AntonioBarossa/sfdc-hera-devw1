public with sharing class HDT_WS_DeactivateCampaign {
    public static wrapResponseGetData callDeactivateCampaign(String campaignId) {
        Datetime dt = Datetime.now();
        Long getTime = dt.getTime();
        Long token=967*(getTime);
        Map<String,Object> getParams = new Map<String,Object>{
            'workPlanName' => campaignId,
            'mostRecentOnly' => true,
            'dateTime' => getTime,
            'token' => String.valueOf(token)
        };
        return  (wrapResponseGetData)HDT_WS_HTTPServiceCall.sendRequest('arrestocampaign', getParams, wrapResponseGetData.class);
    }

    public class wrapResponseGetData extends HDT_WS_Response{
        @AuraEnabled public String data{get;set;} 
    }
}
