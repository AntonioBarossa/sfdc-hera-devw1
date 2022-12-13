@SuppressWarnings('PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces')
public with sharing class HDT_SRV_GarbageMan {

    private static final String REQUEST_PATH = 'TBD';

    private static HDT_UTL_GarbageMan utlGarbage = new HDT_UTL_GarbageMan();

    @TestVisible
    private class HDT_WRP_GarbageManResponse extends HDT_WS_Response
    {

    }

    @TestVisible
    private class HDT_WRP_GarbageManRequest extends HDT_WS_Request
    {

        @TestVisible private String caseId {get;set;}

        @TestVisible private String codiceRichiesta {get;set;}
        
        @TestVisible private Datetime dataInizioAppuntamento {get;set;}
    
        @TestVisible private Datetime dataFineAppuntamento {get;set;}
    
        @TestVisible private String codiceEsito {get;set;}
        
        @TestVisible private String descrizioneEsito {get;set;}
    
        @TestVisible
        private HDT_WRP_GarbageManRequest(Case currentCase) {
            this.caseId = currentCase.Id;
            this.codiceRichiesta = currentCase.WasterCode__c ;
            this.dataInizioAppuntamento = currentCase.StartAppointment__c;
            this.dataFineAppuntamento = currentCase.EndAppointment__c;
            this.codiceEsito = null;
            this.descrizioneEsito = null;
        }
    
        @TestVisible
        private HDT_WRP_GarbageManRequest(Case currentCase, String codiceEsito) {
            this.caseId = currentCase.Id;
            this.codiceRichiesta = currentCase.WasterCode__c;
            this.dataInizioAppuntamento = null;
            this.dataFineAppuntamento = null;
            this.codiceEsito = codiceEsito;
            this.descrizioneEsito = utlGarbage.descrizioneEsiti.get(codiceEsito);        
        }
    }

    private static HDT_WRP_GarbageManResponse doCallout(HDT_WRP_GarbageManRequest req){
		HDT_WRP_GarbageManResponse res = (HDT_WRP_GarbageManResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WRP_GarbageManResponse.class);
		return res;
	}

    @TestVisible 
    private class HDT_QBL_NotifyService implements Finalizer, Queueable, Database.AllowsCallouts {

        private Id caseId {get;set;}

        private String errorCode {
            get{if(STRING.isBlank(errorCode)) errorCode = '99';return errorCode;}
            set;
        }

        public HDT_QBL_NotifyService(){
            return;
        }

        private HDT_QBL_NotifyService(Id caseId){
            this.caseId=caseId;
        }

        public void execute(QueueableContext ctx){

            //HDT_SRV_GarbageMan.HDT_QBL_NotifyService currentClassInstance = new HDT_SRV_GarbageMan.HDT_QBL_NotifyService();
            System.attachFinalizer(this);

            //query case
            List<Case> currentCase = utlGarbage.getCurrentCase(caseId); 

            //query transaction
            List<wrts_prcgvr__PhaseTransition__c> phaseTransaction = utlGarbage.getPhaseTransition('HDT_GestioneRifiuti', currentCase[0].RecordTypeId);
            
            //check phase transaction, se non trovata settare errorCode a 99
            if(phaseTransaction.size() == 0){
                throw new HDT_UTL_HeraException('Phase Transaction not found');
            }

            //chiamata servizio crea esito
            utlGarbage.launchCalloutTemplateSync(currentCase[0].Id, phaseTransaction[0].Id);

            //ri-querare case
            List<Case> caseAftereOutcome = utlGarbage.getCurrentCase(caseId); 

            //check outcome
            if(!'OK'.equalsIgnoreCase(caseAftereOutcome[0].Outcome__c)){
                this.errorCode = '08';
                throw new HDT_UTL_HeraException('The Outcome is KO');
            }
        }

        public void execute(FinalizerContext ctx){

            List<Case> currentCase = utlGarbage.getCurrentCase(caseId); 

            //se queueable success chiamare servizio deda con case
            if(ctx.getResult() == ParentJobResult.SUCCESS){
                HDT_WRP_GarbageManResponse responseDeda = doCallout(new HDT_WRP_GarbageManRequest(currentCase[0]));
            }else{
                //se queueable fallita chiamare servizio deda con case e error code
                HDT_WRP_GarbageManResponse responseDeda = (HDT_WRP_GarbageManResponse) doCallout(new HDT_WRP_GarbageManRequest(currentCase[0], this.errorCode));
            }
        }
    }

    
    private class HDT_QBL_ScheduleAppointment implements Finalizer, Queueable, Database.AllowsCallouts {

        Id caseId {get;set;}
        String errorCode {
            get{if(STRING.isBlank(errorCode)) errorCode = '99';return errorCode;}
            set;
        }

        HDT_QBL_ScheduleAppointment(Id caseId){
            this.caseId = caseId;
        }

        public HDT_QBL_ScheduleAppointment(){
            return;
        }

        public void execute(QueueableContext ctx){

            System.attachFinalizer(this);

            Case currentCase = utlGarbage.getCurrentCase(caseId)[0];
            
            //Chiamata al servizio Ricerca Appuntamento 
            String street = currentCase.InvoicingStreetName__c + currentCase.InvoicingStreetNumber__c + currentCase.InvoicingPostalCode__c + currentCase.InvoicingCity__c;
            HDT_LC_AppointmentTariAgenda.HDT_WRP_DataApp wrpDataApp = new HDT_LC_AppointmentTariAgenda.HDT_WRP_DataApp (this.caseid, currentCase.InvoicingStreetCode__c, 
            street, currentCase.InvoicingStreetNumber__c, currentCase.TypeOperation__c, currentCase.InvoicingCity__c);
            HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentSearchResponse response = HDT_LC_AppointmentTariAgenda.handleSearch(wrpDataApp);

            if(response?.data?.appointmentData?.isEmpty()){
                errorCode= '06';
                throw new HDT_UTL_HeraException('Slot not found'); 
            }else{
                wrpDataApp.startDate = Datetime.newInstance(Long.valueOf(response.data.appointmentData[0].startDate));
                wrpDataApp.endDate = Datetime.newInstance(Long.valueOf(response.data.appointmentData[0].endDate));
                HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentConfirmResponse res = HDT_LC_AppointmentTariAgenda.handleConfirm(currentCase, wrpDataApp);
                if(String.isBlank(res?.data?.noticeNumber)){
                    errorCode= '07';
                    throw new HDT_UTL_HeraException('Unable to confirm appointment'); 
                }
            }
            return;
        }
            
        public void execute(FinalizerContext ctx){

            Case currentCase = utlGarbage.getCurrentCase(caseId)[0];

            //se queueable success accodare la queueable HDT_QBL_NotifyService passandogli il CaseId
            if(ctx.getResult() == ParentJobResult.SUCCESS){
                System.enqueueJob(new HDT_QBL_NotifyService(currentCase.Id));
            }else{
                //se queueable fallita chiamare servizio deda con case e error code
                doCallout(new HDT_WRP_GarbageManRequest(currentCase, this.errorCode));
                //aggiornare il Case in Fase Annullata e Stato Chiuso
                currentCase.Phase__c = 'Annullato';
                currentCase.Status = 'Closed';
                HDT_UTL_DatabaseService.updateSObject(currentCase);
            }
        }
    }

    public static void scheduleAppointment(Id caseId){
        HDT_QBL_ScheduleAppointment runJob = new HDT_QBL_ScheduleAppointment(caseId);
        System.enqueueJob(runJob);
    }
}
