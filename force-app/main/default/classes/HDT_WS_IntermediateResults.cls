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

        private List<Sobject> populateSobjForUpdate(HDT_WRP_Reminder calloutCaseDt, Case originalCase){
            List<Sobject> retList = new List<Sobject>();
            try{
                Case caseToUpdate = new Case();
                caseToUpdate.Id= calloutCaseDt.caseId;

                // popola phase con condizione
                Map<String, String> codToPhase = new Map<String, String>{
                    '0050'=>'Approvata',
                    '0007'=>'Rifiutata',
                    '0060'=>'Presa In Carico'
                };
                // if('Avviso di Servizio'.equalsIgnoreCase(originalCase.Type)) 
                //     caseToUpdate.Phase__c = codToPhase.get(calloutCaseDt.field[0].codNota);
                // else caseToUpdate.Phase__c = calloutCaseDt.field[0].phase;
                caseToUpdate.Phase__c = 'Avviso di Servizio'.equalsIgnoreCase(originalCase.Type)? codToPhase.get(calloutCaseDt.field[0].codNota) : calloutCaseDt.field[0].phase;

                // mergiate le 4 info all’interno del campo “Description”
                caseToUpdate.Description = 'Codice Activity: '+calloutCaseDt.field[0].codActivity+'\n'+
                                           'Codice Nota: *'+calloutCaseDt.field[0].codNota+'*'+'\n'+
                                           'Descrizione Nota: '+calloutCaseDt.field[0].descNota+'\n'+
                                           'Testo Nota: '+calloutCaseDt.field[0].textNota;

                //c.exampleActivityCode = caseData.field[0].codActivity;
                //Try Save all data
                retList.add(caseToUpdate);
                if('Avviso di Servizio'.equalsIgnoreCase(originalCase.Type) && !'Presa In Carico'.equalsIgnoreCase(caseToUpdate.Phase__c) && originalCase.Order__c!=null){
                    retList.add(this.populateOrder(caseToUpdate.Phase__c, originalCase.Order__c));
                } 
            }catch(Exception e){
                this.errorLog.add(calloutCaseDt.caseId+'\t'+calloutCaseDt.noticeId+'\t'+'Exception Thrown '+e.getMessage());
            }
            return retList;
        }

        private Order populateOrder(String casePhase, Id orderId){
            Order orderToUpdate = new Order();
            orderToUpdate.Id = orderId;
            /* controllo Phase */
            if(casePhase=='Approvata'){
                orderToUpdate.Phase__c = 'Comunicazione Verso Heroku';
            } else if(casePhase=='Rifiutata'){
                orderToUpdate.Phase__c = 'Annullata';
                orderToUpdate.CancellationReason__c = 'Mancanza del presupposto';
            }
            return orderToUpdate;
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

    @TestVisible
    private class HDT_WRP_Request{
        @TestVisible String requestId {get;set;}
        @TestVisible String dataRequest {get;set;}
        @TestVisible List<HDT_WRP_Reminder> reminder {get;set;}
    }

    @TestVisible
    private class HDT_WRP_Reminder {
		@TestVisible String caseId {get;set;}
		@TestVisible String noticeId {get;set;}
		@TestVisible List<HDT_WRP_Field> field {get;set;}
	}

    @TestVisible
    private class HDT_WRP_Field {
		@TestVisible String codActivity {get;set;}
		@TestVisible String codNota {get;set;}
		@TestVisible String descNota {get;set;}
		@TestVisible String textNota {get;set;}
		@TestVisible String phase {get;set;}
	}

}