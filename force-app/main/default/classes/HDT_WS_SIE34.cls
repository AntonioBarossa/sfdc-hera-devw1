public with sharing class HDT_WS_SIE34 {
    private static final String REQUEST_PATH = '/jobs/sie/sie-34/exports';
    public static HDT_WS_SIE34DataResponse callService(String runId,String status,String fileType,String errorMessage,List<String> contentVersionIds){
        
        HDT_WS_SIE34DataRequest req = new HDT_WS_SIE34DataRequest(runId,status,fileType,errorMessage,contentVersionIds);
		HDT_WS_SIE34DataResponse res = (HDT_WS_SIE34DataResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req,HDT_WS_SIE34DataResponse.class);
        
        return res;
    }

}
