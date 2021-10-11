public with sharing class HDT_WS_DeactivateCampaign {
    public static wrapRequestObject requestDeactivateCampaign(String campaignId){
        Datetime dt = Datetime.now();
        Long getTime = dt.getTime();
        Long token=967*(getTime);
        Map<String,String> getParams = new Map<String,String>{
            'workPlanName' => campaignId,
            'mostRecentOnly' => 'true',
            'dateTime' => String.valueOf(getTime),
            'token' => String.valueOf(token)
        };
        wrapRequestObject reqObj = new wrapRequestObject();
        reqObj.params = getParams;
        return reqObj;
    }

    public static wrapResponseGetData callDeactivateCampaign(List<wrapRequestObject> requestList) {
        return  (wrapResponseGetData)HDT_WS_HTTPServiceCall.sendRequest('arrestocampaign', requestList, wrapResponseGetData.class);
    }

    public class wrapResponseGetData extends HDT_WS_Response{
        @AuraEnabled public String data{get;set;} 
    }

    public class wrapRequestObject extends HDT_WS_Request{
        @AuraEnabled public Map<String,String> params{get;set;} 
    }
}
