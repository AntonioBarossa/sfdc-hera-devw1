public with sharing class HDT_WS_SIE34 {

    public static HDT_WS_SIE34DataResponse callService(String runId,String status,String fileType,String errorMessage,List<String> contentVersionIds){
        
        HDT_WS_SIE34DataRequest req = new HDT_WS_SIE34DataRequest(runId,status,fileType,errorMessage,contentVersionIds);
		HDT_WS_SIE34DataResponse res = (HDT_WS_SIE34DataResponse)HDT_WS_HTTPServiceCall.sendRequest('SIE34', req,HDT_WS_SIE34DataResponse.class);
        
        return res;
    }

}
