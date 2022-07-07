@RestResource(urlMapping='/batch-manager/run-batch/*')
global with sharing class HDT_WS_RunBatch {
    
    @HttpPost
    webservice static void runBatch() {
        String body = RestContext.request.requestBody.toString();
        HDT_WRP_RunBatchRequest request = (HDT_WRP_RunBatchRequest) JSON.deserialize(body,HDT_WRP_RunBatchRequest.Class);
        HDT_WRP_RunBatchResponse response = new HDT_WRP_RunBatchResponse();
        String runId = request.runId;
        response.runId = runId;
        String batchName = request.batchName;
        if(String.isNotBlank(batchName)){
            HDT_BatchMapping__mdt mapping = HDT_BatchMapping__mdt.getInstance(batchName);
            Integer size = mapping!=null && mapping.BatchSize__c!=null && mapping.BatchSize__c!=0 ? Integer.valueOf(mapping.BatchSize__c) : 200;
            Type className = Type.forName(batchName);
            if(batchName.equalsIgnoreCase('HDT_BA_RiconciliazioneSubscriptions')){
                HDT_BA_RiconciliazioneSubscriptions ba = new HDT_BA_RiconciliazioneSubscriptions(runId);
                Database.executeBatch(ba,size);
            }else if(className != null){
                Object bInstance = className.newInstance();
                if(bInstance != null){
                    try{
                        Database.executeBatch((Database.Batchable<sObject>) bInstance, size);
                        RestContext.response.statusCode = 200;
                    }catch(Exception e){
                        RestContext.response.statusCode = 400;
                    }
                }
            }else {
                RestContext.response.statusCode = 400;
            }
        }else {
            RestContext.response.statusCode = 400;
        }
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
        RestContext.response.headers.put('Content-Type', 'application/json');
    }

    public class HDT_WRP_RunBatchRequest{
        String runId;
        String batchName;
    }

    public class HDT_WRP_RunBatchResponse{
        String runId;
    }

}
