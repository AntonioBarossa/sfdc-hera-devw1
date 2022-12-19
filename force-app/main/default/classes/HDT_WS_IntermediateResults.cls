@RestResource(urlMapping='/IntermediateResults/*')
global with sharing class HDT_WS_IntermediateResults {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();

    private static final Map<String, String> COD_TO_PHASE = new Map<String, String>{
        '0050'=>'Approvata',
        '0007'=>'Rifiutata',
        '0060'=>'Presa In Carico'
    };

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
            Map<Id, Case> mapCases = new Map<Id, Case>(caseQr.getRecordsById(caseIds, 'Id, Type, Order__c, Phase__c'));
            List<Sobject> sobjectsToUpdate = new List<Sobject>();
            for(HDT_WRP_Reminder caseData : this.request.reminder){
                this.populateSobjForUpdate(caseData, mapCases.get(caseData.caseId), sobjectsToUpdate);
            }
            
            List<Database.SaveResult> saveResults = Database.update(removeDuplicateSobjects(sobjs), false);
            this.insertLog(saveResults);
            return;
        }

        private void populateSobjForUpdate(HDT_WRP_Reminder calloutCaseDt, Case originalCase, List<Sobject> sobjectsToUpdate){
            try{
                Case caseToUpdate = new Case(Id = calloutCaseDt.caseId);
                HDT_WRP_Field fieldInfos = calloutCaseDt.field[calloutCaseDt.field.size()-1];

                // popola phase con condizione
                
                // if('Avviso di Servizio'.equalsIgnoreCase(originalCase.Type)) 
                //     caseToUpdate.Phase__c = COD_TO_PHASE.get(fieldInfos.codNota);
                // else caseToUpdate.Phase__c = fieldInfos.phase;
                caseToUpdate.Phase__c = 'Avviso di Servizio'.equalsIgnoreCase(originalCase.Type)? COD_TO_PHASE.get(fieldInfos.codNota) : fieldInfos.phase;
                if(STRING.isBlank(caseToUpdate.Phase__c)){
                    caseToUpdate.Phase__c = originalCase.Phase__c;
                    caseToUpdate.Description = 'Errore aggiornamento nota con codice '+ fieldInfos.codNota + '\nCodice Nota non valido per il caso selezionato.';
                    sobjectsToUpdate.add(caseToUpdate);
                    return;
                }
                // mergiate "descNota" e "textNota" all’interno del campo “Description”
                caseToUpdate.Description = //'Codice Activity: '+fieldInfos.codActivity+'\n'+
                                           //'Codice Nota: *'+fieldInfos.codNota+'*'+'\n'+
                                           'Descrizione Nota: '+fieldInfos.descNota+'\n'+
                                           'Testo Nota: '+fieldInfos.textNota;

                // passati "codActivity" e "codNota" nei rispettivi campi su Case
                caseToUpdate.ActivityCode__c = fieldInfos.codActivity;
                caseToUpdate.NoteCode__c = fieldInfos.codNota;

                //c.exampleActivityCode = caseData.field[0].codActivity;
                //Try Save all data
                sobjectsToUpdate.add(caseToUpdate);
                if('Avviso di Servizio'.equalsIgnoreCase(originalCase.Type) && !'Presa In Carico'.equalsIgnoreCase(caseToUpdate.Phase__c) && originalCase.Order__c!=null){
                    sobjectsToUpdate.add(this.populateOrder(caseToUpdate.Phase__c, originalCase.Order__c));
                } 
            }catch(Exception e){
                this.errorLog.add(calloutCaseDt.caseId+'\t'+calloutCaseDt.noticeId+'\t'+'Exception Thrown '+e.getMessage());
            }
        }

        private Order populateOrder(String casePhase, Id orderId){
            Order orderToUpdate = new Order();
            orderToUpdate.Id = orderId;
            /* controllo Phase */
            if(casePhase=='Approvata'){
                orderToUpdate.Phase__c = 'Documentazione Validata';
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

        private List<Sobject> removeDuplicateSobjects(List<SObject> listWithDuplicates){
            Map<Id, Sobject> tempMap = new Map<Id, Sobject>();
            for(SObject sobj : listWithDuplicates){
                tempMap.put(sobj.Id, sobj);
            }
            return tempMap.values();
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