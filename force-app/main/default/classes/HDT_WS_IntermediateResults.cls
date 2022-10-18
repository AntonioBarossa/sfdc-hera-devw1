@RestResource(urlMapping='/IntermediateResults/*')
global with sharing class HDT_WS_IntermediateResults {

    @HttpPost
    global static HDT_WRP_Response postIntermediateResults()  {
        HDT_WRP_Response response;
        try{
            String body = RestContext.request.requestBody.toString();
            HDT_SRV_ServiceTwentySix.insertCalloutLog('OK', body, '');
            HDT_WRP_Request request = (HDT_WRP_Request) JSON.deserialize(body, HDT_WS_IntermediateResults.HDT_WRP_Request.class);
            //launch async job
            HDT_QBL_IntermediateResultsJob job = new HDT_QBL_IntermediateResultsJob(request);
            System.enqueueJob(job);
        }catch(Exception e){
            return new HDT_WRP_Response('failed', e.getMessage());
        }

        return new HDT_WRP_Response('success');
    }

    public class HDT_QBL_IntermediateResultsJob implements Queueable{
        HDT_WRP_Request request;

        HDT_QBL_IntermediateResultsJob(HDT_WRP_Request request){
            this.request=request;
        }

        public void execute(QueueableContext context) {
            //salva gli esiti intermedi
            return;
        }
    }

    global class HDT_WRP_Response{
        String status {get;set;}
        String errorMsg {get;set;}
        String timestamp {get;set;}
        HDT_WRP_Response(String status){
            this.status=status;
            this.timestamp = String.valueOf(DateTime.now());
        }
        HDT_WRP_Response(String status, String error){
            this.status=status;
            this.errorMsg=error;
            this.timestamp = String.valueOf(DateTime.now());
        }
    }

    private class HDT_WRP_Request{
        String requestId {get;set;}
        String dataRequest {get;set;}
        List<HDT_WRP_Reminder> reminder {get;set;}
    }

    private class HDT_WRP_Reminder {
		String caseId {get;set;}
		String noticeId {get;set;}
		List<HDT_WRP_Field> field {get;set;}
	}

    private class HDT_WRP_Field {
		String codActivity {get;set;}
		String codNota {get;set;}
		String descNota {get;set;}
		String textNota {get;set;}
		String phase {get;set;}
	}

}
