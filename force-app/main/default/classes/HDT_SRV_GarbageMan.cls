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

    private static HDT_WRP_GarbageManResponse doCallout(HDT_WRP_GarbageManRequest req){
		HDT_WRP_GarbageManResponse res = (HDT_WRP_GarbageManResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH,'POST', req, HDT_WRP_GarbageManResponse.class);
		return res;
	} 

}
