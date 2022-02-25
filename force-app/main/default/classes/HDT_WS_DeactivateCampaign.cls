public with sharing class HDT_WS_DeactivateCampaign {
    private static final String REQUEST_PATH = '/campaigns/workgroups';
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
        return  (wrapResponseGetData)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'PUT', getParams, wrapResponseGetData.class);
    }

    public class wrapResponseGetData extends HDT_WS_Response{
        @AuraEnabled public String data{get;set;} 
    }
}
