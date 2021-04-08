global inherited sharing class HDT_WRP_HerokuPostSalesManager {


    public Map<String, String> responseMap = new Map<String, String>();
    public Map<String, String> requestMap = new Map<String, String>();

    global HDT_WRP_HerokuPostSalesManager(String requestType, 
        String result, 
        String errorMessage, 
        String refReq, 
        String communicationChannel, 
        String reqId,
        String herokuCode){

        this.responseMap.put('requestType', requestType);
        this.responseMap.put('result', result);
        this.responseMap.put('errorMessage', errorMessage);
        this.responseMap.put('refReq', refReq);
        this.responseMap.put('communicationChannel', communicationChannel);
        this.responseMap.put('reqId', reqId);
        this.responseMap.put('herokuCode', herokuCode);


    }

    global HDT_WRP_HerokuPostSalesManager(String flowType, String phase, String recordId){
        
        this.requestMap.put('flowType', flowType);
        this.requestMap.put('phase', phase);
        this.requestMap.put('recordId', recordId);

    }


}
