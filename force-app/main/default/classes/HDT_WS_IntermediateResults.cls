@RestResource(urlMapping='/IntermediateResults/*')
global with sharing class HDT_WS_IntermediateResults {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();

    @HttpPost
    global static HDT_WRP_Response postIntermediateResults()  {
        try{
            String body = RestContext.request.requestBody.toString();
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

        private List<String> errorLog = new List<String>{'caseId\tnoticeId\terror'};

        HDT_QBL_IntermediateResultsJob(HDT_WRP_Request request){
            this.request=request;
        }

        public void execute(QueueableContext context) {
            //salva gli esiti intermedi
            List<Id> caseIds = new List<Id>();
            for(HDT_WRP_Reminder caseData : this.request.reminder){
                caseIds.add(caseData.caseId);
            }
            Map<Id, Case> mapCases = new Map<Id, Case>(caseQr.getRecordsById(caseIds, 'Id, Type, Order__c'));
            List<Sobject> sobjs = new List<Sobject>();
            for(HDT_WRP_Reminder caseData : this.request.reminder){
                sobjs.addAll(this.populateSobjForUpdate(caseData, mapCases.get(caseData.caseId)));
            }
            List<Database.SaveResult> saveResults = Database.update(sobjs, false);
            this.insertLog(saveResults);
            return;
        }

        private List<Sobject> populateSobjForUpdate(HDT_WRP_Reminder caseData, Case originalCase){
            List<Sobject> retList = new List<Sobject>();
            try{
                Case c = new Case();
                c.Id= caseData.caseId;
                c.Phase__c = caseData.field[0].phase;
                //c.exampleActivityCode = caseData.field[0].codActivity;
                //Try Save all data
                retList.add(c);
                if('Avviso di Servizio'.equalsIgnoreCase(originalCase.Type) && 'Completata'.equalsIgnoreCase(c.Phase__c) && originalCase.Order__c!=null){
                    retList.add(this.populateOrder(caseData, originalCase.Order__c));
                } 
            }catch(Exception e){
                this.errorLog.add(caseData.caseId+'\t'+caseData.noticeId+'\t'+'Exception Thrown '+e.getMessage());
            }
            return retList;
        }

        private Order populateOrder(HDT_WRP_Reminder caseData, Id orderId){
            return null;
        }

        private void insertLog(List<Database.SaveResult> saveResults){
            for(Database.SaveResult sr : saveResults){
                if(sr.isSuccess()){         continue;       }

                String errorMsg = 'SaveErrors: ';
                for(Database.Error err : sr.getErrors()){
                    errorMsg+=err.getMessage()+' for fields '+ err.getFields();
                }
                this.errorLog.add(sr.getId()+'\t'+'-'+'\t'+errorMsg);
            }
            HDT_SRV_ServiceTwentySix.insertCalloutLog(this.request.requestId, JSON.serialize(this.request), STRING.join(this.errorLog, '\n'));
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
