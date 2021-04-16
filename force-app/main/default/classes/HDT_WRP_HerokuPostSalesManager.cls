global inherited sharing class HDT_WRP_HerokuPostSalesManager {


    public Map<String, String> responseMap = new Map<String, String>();
    public Map<String, String> requestMap = new Map<String, String>();

    global HDT_WRP_HerokuPostSalesManager(String requestType, 
        String result, 
        String errorMessage, 
        String refReq, 
        String communicationChannel, 
        String reqId,
        String herokuCode,
        String dlCode){

        this.responseMap.put('requestType', requestType);
        this.responseMap.put('result', result);
        this.responseMap.put('errorMessage', errorMessage);
        this.responseMap.put('refReq', refReq);
        this.responseMap.put('communicationChannel', communicationChannel);
        this.responseMap.put('reqId', reqId);
        this.responseMap.put('herokuCode', herokuCode);
        this.responseMap.put('dlCode', dlCode);


    }

    global HDT_WRP_HerokuPostSalesManager(String flowType, String phase, String recordId, String herokuCode,String contractCode,String contractStatus,String dlCode){
        
        this.requestMap.put('flowType', flowType);
        this.requestMap.put('phase', phase);
        this.requestMap.put('recordId', recordId);
        this.requestMap.put('herokuCode', herokuCode);
        this.responseMap.put('dlCode', dlCode);
        this.requestMap.put('contractCode', contractCode);
        this.requestMap.put('contractStatus', contractStatus);

    }

    global HDT_WRP_HerokuPostSalesManager(List<wrts_prcgvr.MRR_1_0.Field> fieldList,String requestType){
        for(wrts_prcgvr.MRR_1_0.Field fld : fieldList){
            responseMap.put(fld.value,fld.value);
        }
        responseMap.put('REQUEST_TYPE',requestType);
    }
    
    public HDT_WRP_HerokuPostSalesManager(List<HDT_WRP_MrrRequest.HDT_WRP_Field> fieldList){
        for(HDT_WRP_MrrRequest.HDT_WRP_Field fld : fieldList){
            requestMap.put(fld.value,fld.value);
        }
    }


}