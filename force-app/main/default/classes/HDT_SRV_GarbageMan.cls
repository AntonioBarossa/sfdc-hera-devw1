public with sharing class HDT_SRV_GarbageMan {

    private static final String REQUEST_PATH = 'TBD';

    private static final Map<String, String> descrizioneEsiti = new Map<String, String> {
        '01' => 'StreetCode, Comune, Indirizzo, Civico non valorizzati',
        '02' => 'CodiceFiscale e NominativoContatto entrambi non valorizzati',
        '03' => 'Indirizzo non trovato',
        '04' => 'Nessuna data disponibile in fase di Richiesta appuntamento',
        '05' => 'Errore in fase di Creazione RDS',
        '06' => 'Errore in fase di Richiesta appuntamento',
        '07' => 'Errore in fase di Conferma appuntamento',
        '08' => 'Errore in fase di Invio RDS verso SAP',
        '99' => 'Errore generico'
    };

    public virtual class HDT_WRP_GarbageManResponse extends HDT_WS_Response
    {

    }

    public virtual class HDT_WRP_GarbageManRequest extends HDT_WS_Request
    {

        public String caseId {get;set;}

        public String codiceRichiesta {get;set;}
        
        public Datetime dataInizioAppuntamento {get;set;}
    
        public Datetime dataFineAppuntamento {get;set;}
    
        public String codiceEsito {get;set;}
        
        public String descrizioneEsito {get;set;}
    
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
            this.descrizioneEsito = descrizioneEsiti.get(codiceEsito);        
        }

    }

    private  class HDT_QBL_NotifyService implements Finalizer, Queueable{

        public Id caseId {get;set;}

        public String errorCode {get;set;}

        public void execute(QueueableContext ctx){

            HDT_SRV_GarbageMan.HDT_QBL_NotifyService currentClassInstance = new HDT_SRV_GarbageMan.HDT_QBL_NotifyService();
            System.attachFinalizer(currentClassInstance);

            //query case
            List<Case> currentCase = [  SELECT Id, WasterCode__c, StartAppointment__c, EndAppointment__c, RecordTypeId
                                        FROM Case
                                        WHERE Id =: this.caseId 
                                        WITH SECURITY_ENFORCED
                                        LIMIT 1]; 

            //query transaction
            List<wrts_prcgvr__PhaseTransition__c> phaseTransaction = [  SELECT Id 
                                                                        FROM wrts_prcgvr__PhaseTransition__c 
                                                                        WHERE wrts_prcgvr__CalloutTemplate__c = 'HDT_GestioneRifiuti' 
                                                                        AND wrts_prcgvr__RecordTypeId__c = :currentCase[0].RecordTypeId
                                                                        WITH SECURITY_ENFORCED
                                                                        LIMIT 1];
            
            //check phase transaction, se non trovata settare errorCode a 99
            if(phaseTransaction.size() == 0){
                this.errorCode = '99';
                throw new HDT_UTL_HeraException('Phase Transaction not found');
            }

            //chiamata servizio crea esito
            outcomeGeneration(currentCase[0].Id, phaseTransaction[0].Id);

            //ri-querare case
            List<Case> caseAftereOutcome = [SELECT Id, Outcome__c
                                            FROM Case
                                            WHERE Id =: caseId 
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1]; 

            //check outcome
            if('OK'.equalsIgnoreCase(caseAftereOutcome[0].Outcome__c)){
                return;
            }else{
                this.errorCode = '08';
                throw new HDT_UTL_HeraException('The Outcome is KO');
            }

        }

        public void execute(FinalizerContext ctx){

            List<Case> currentCase = [  SELECT Id, WasterCode__c, StartAppointment__c, EndAppointment__c, RecordTypeId
                                        FROM Case
                                        WHERE Id =: caseId 
                                        WITH SECURITY_ENFORCED
                                        LIMIT 1]; 

            //se queueable success chiamare servizio deda con case
            if(ctx.getResult() == ParentJobResult.SUCCESS){
                HDT_SRV_GarbageMan.HDT_WRP_GarbageManResponse responseDeda = doCallout(new HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest(currentCase[0]));
            }else{
            //se queueable fallita chiamare servizio deda con case e error code
                if(''.equalsIgnoreCase(this.errorCode) || this.errorCode == null){
                    this.errorCode = '99';
                }
                HDT_SRV_GarbageMan.HDT_WRP_GarbageManResponse responseDeda = (HDT_SRV_GarbageMan.HDT_WRP_GarbageManResponse) doCallout(new HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest(currentCase[0], this.errorCode));
            }
        }

        private void outcomeGeneration(Id sobjId, Id tasactionId){
            //Select all fields from a Sobject START
            Schema.DescribeSObjectResult descSobj = ((Id) sobjId).getSobjectType().getDescribe();

            Map<String, Schema.SObjectField> M = descSobj.fields.getMap();
            String queryStatement = 'SELECT '+STRING.join(new List<String>(M.keySet()), ', ')+ ' FROM '+descSobj.getName()+ ' WHERE Id=:sobjId LIMIT 1';
            //system.debug(queryStatement);
            List<Sobject> sobjs = Database.Query(queryStatement);

            //Select All Fields From a Sobject END


            String transQuery = 'SELECT '+ STRING.join(new List<String>(Schema.SObjectType.wrts_prcgvr__PhaseTransition__c.fields.getMap().keySet()), ', ') + ' FROM wrts_prcgvr__PhaseTransition__c WHERE Id=:idTransition LIMIT 1';

            wrts_prcgvr__PhaseTransition__c transition = Database.Query(transQuery);
            Matcher matcher=Pattern.compile('^(.+)\\(method="(.+)"\\);').matcher(transition.wrts_prcgvr__ApexCalloutActions__c);
            String className = matcher.find()? matcher.group(1) : null;
            if(STRING.isBlank(className))   throw new HDT_UTL_HeraException('Error class not found');

            String method =  matcher.group(2);

            wrts_prcgvr.Interfaces_1_0.IApexCalloutAction callout = (wrts_prcgvr.Interfaces_1_0.IApexCalloutAction) Type.forName(className).newInstance();

            Map<String,Object> argsMap = new Map<String,Object>();
            argsMap.put('sender', sobjs[0]);
            argsMap.put('transition', transition);
            argsMap.put('method', method);
            argsMap.put('parameters', new Map<String,String>());

            callout.execute(argsMap);
        }

    }

    private static HDT_WRP_GarbageManResponse doCallout(HDT_WRP_GarbageManRequest req){
		HDT_WRP_GarbageManResponse res = (HDT_WRP_GarbageManResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WRP_GarbageManResponse.class);
		return res;
	}



}
