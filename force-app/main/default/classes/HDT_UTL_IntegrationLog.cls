public without sharing class HDT_UTL_IntegrationLog {
    
    public static void handleMrrRequest(String request, String error){
        List<Integration_Log__c> integList = new List<Integration_Log__c>();
        HDT_WRP_MrrRequest.HDT_WRP_Request postSalesRequest = new HDT_WRP_MrrRequest.HDT_WRP_Request();
        HDT_UTL_HerokuPostSalesManager hpsmUtl = new HDT_UTL_HerokuPostSalesManager();
        HDT_WRP_MrrRequest requestBody = (HDT_WRP_MrrRequest) JSON.deserialize(request, HDT_WRP_MrrRequest.class);
        postSalesRequest = requestBody.requests[0];
        HDT_WRP_HerokuPostSalesManager reqWrp = hpsmUtl.manipulateRequest(postSalesRequest);
        String recordId = reqWrp.requestMap.get('RECORD_ID');
        String method = reqWrp.requestMap.get('METHOD');
        String processNumber = reqWrp.requestMap.get('SALESFORCE_KEY');
        HDT_WRP_IntegrationLog wrapObj = createWrapper(request,'MRR_Request',method,processNumber,recordId,error);
        Integration_Log__c recordObject = createSobject(wrapObj);
        integList.add(recordObject);
        insertLogList(integList);

    }
    
    private static void insertLogList(List<Integration_Log__c> logList){
        if (logList != null && !logList.isEmpty()) {
            HDT_UTL_DatabaseService.insertSObject(logList);
        }
    }

    private static Integration_Log__c createSobject(HDT_WRP_IntegrationLog wrapObject){
        Integration_Log__c instanceObject = new Integration_Log__c();
        instanceObject.Method__c = wrapObject.method;
        instanceObject.Process_Number__c = wrapObject.processNumber;
        instanceObject.RecordId__c = wrapObject.recordId;
        instanceObject.Request__c = wrapObject.request;
        instanceObject.WebService__c = wrapObject.webServiceName;
        instanceObject.Error__c = wrapObject.error;
        return instanceObject;
    }

    private static HDT_WRP_IntegrationLog createWrapper(String request,String webServiceName,String method,String processNumber,String recordId,String error){
        HDT_WRP_IntegrationLog wrapObject = new HDT_WRP_IntegrationLog();
        wrapObject.request = request;
        wrapObject.webServiceName = webServiceName;
        wrapObject.method = method;
        wrapObject.processNumber = processNumber;
        wrapObject.recordId = recordId;
        wrapObject.error = error;
        return wrapObject;
    }

    public class HDT_WRP_IntegrationLog{
        public String request;
        public String webServiceName;
        public String method;
        public String processNumber;
        public String recordId;
        public String error;

        public HDT_WRP_IntegrationLog(){}
    }
}
