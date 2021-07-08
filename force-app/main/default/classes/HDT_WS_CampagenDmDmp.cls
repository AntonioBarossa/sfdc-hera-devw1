public with sharing class HDT_WS_CampagenDmDmp {

    public static HDT_WS_CampagenDmDmpDataResponse callService(String runId,String fileType,List<String> contentVersionIds){
        
        HDT_WS_CampagenDmDmpDataRequest req = new HDT_WS_CampagenDmDmpDataRequest(runId,fileType,contentVersionIds);
		HDT_WS_CampagenDmDmpDataResponse res = (HDT_WS_CampagenDmDmpDataResponse)HDT_WS_HTTPServiceCall.sendRequest('CampagenDmDmpData', req,HDT_WS_CampagenDmDmpDataResponse.class);
        
        return res;
    }

}
