public with sharing class HDT_SRV_GarbageMan {

    public class HDT_WRP_GarbageMan
    {
        public String  caseId {get;set;}

        public String  codiceIdRichiesta {get;set;}
        
        public Date  dataInizioAppuntamento {get;set;}
    
        public Date  dataFineAppuntamento {get;set;}
    
        public String  codiceEsito {get;set;}
    
        public String  descrizioneEsito {get;set;}
    
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
    
        public HDT_WRP_GarbageMan(Case currentCase) {
            this.caseId = currentCase.Id;
            this.codiceRichiesta = currentCase.AppointmentCode__c;
            this.dataInizioAppuntamento = currentCase.StartAppointment__c;
            this.dataFineAppuntamento = currentCase.EndAppointment__c;
            this.codiceEsito = null;
            this.descrizioneEsito = null;
        }
    
        public HDT_WRP_GarbageMan(Case currentCase, String codiceEsito) {
            this.caseId = currentCase.Id;
            this.codiceRichiesta = currentCase.AppointmentCode__c;
            this.dataInizioAppuntamento = null;
            this.dataFineAppuntamento = null;
            this.codiceEsito = codiceEsito;
            this.descrizioneEsito = descrizioneEsiti.get(codiceEsito);        
        }

    }

    

}
