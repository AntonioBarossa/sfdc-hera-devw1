/*
Libreria Errori
    ERR-0000 : Metodo non gestito.
    ERR-0001 : Errore generico nel metodo getCancellationReason
    ERR-0002 : Errore generico nel metodo getListCanellationReason
    ERR-0003 : Dati di input parziali o assenti
*/
public inherited sharing class HDT_UTL_CaseCancellation {

    @InvocableMethod
    public static List<HDT_UTL_ResponseCancellationReason>  dispatchMethod(List<HDT_UTL_RequestCancellationReason> inputs) {
        List<HDT_UTL_ResponseCancellationReason> toReturn = new List<HDT_UTL_ResponseCancellationReason>();
        if(inputs != null && inputs.size() > 0){
            switch on inputs[0].method {
                when 'getCancellationReason' {
                    toReturn.add(getCancellationReason(Inputs[0]));
                    return toReturn;
                }
                when 'getListCancellationReason'{
                    toReturn.add(getListCanellationReason(inputs[0]));
                    return toReturn;
                }
                when else {
                    toReturn.add(new HDT_UTL_ResponseCancellationReason('KO','ERR-0000'));
                    return toReturn;
                }
            }
        }else {
            toReturn.add(new HDT_UTL_ResponseCancellationReason('KO','ERR-0003'));
            return toReturn;
        }
    }

    public static HDT_UTL_ResponseCancellationReason getCancellationReason(HDT_UTL_RequestCancellationReason input) {
        HDT_UTL_ResponseCancellationReason toReturn;
        try{
            List<String> listDescription = new List<String>();
            String queryCmd = 'SELECT Technical_Causal_Cancellation_Reason__c, CancellationReasonDescription__c FROM HDT_TechnicalCancellationReason__mdt WHERE Causal_Process_to_Cancell__c = \''
            + input.causalCode +'\' AND SelectedProcessCancellationReason__c = \''
            + input.processCancellationReason +'\' WITH SECURITY_ENFORCED';
            List<HDT_TechnicalCancellationReason__mdt> technicalCancellationReasonList = Database.query(queryCmd);
            if(technicalCancellationReasonList != null && technicalCancellationReasonList.size()>0){
                toReturn = new HDT_UTL_ResponseCancellationReason(technicalCancellationReasonList[0].Technical_Causal_Cancellation_Reason__c, technicalCancellationReasonList[0].CancellationReasonDescription__c,'OK','Causale ricavata con successo',null);
            }else{
                toReturn = new HDT_UTL_ResponseCancellationReason('KO','ERR-0001: Nessuna causale di annullamento identificata');
            }
        }catch(Exception e){
            toReturn = new HDT_UTL_ResponseCancellationReason('KO','ERR-0001: ' +e.getMessage());
        }
        return toReturn;
    }

    @AuraEnabled(cacheable=true)
    public static String getListCanellationReasonLwc(String input){
        HDT_UTL_RequestCancellationReason inputLwc =  (HDT_UTL_RequestCancellationReason) JSON.deserialize(input, HDT_UTL_RequestCancellationReason.class);
        return JSON.serialize(getListCanellationReason(inputLwc));
    }

    public static HDT_UTL_ResponseCancellationReason getListCanellationReason(HDT_UTL_RequestCancellationReason input){
        HDT_UTL_ResponseCancellationReason toReturn;
        try{
            List<HDT_UTL_Option> listDescription = new List<HDT_UTL_Option>();
            String queryCmd = 'SELECT Process_Cancellation_Reason__c FROM HDT_ProcessCancellationReason__mdt WHERE (RecordType__c = NULL OR RecordType__c = \''
            + input.recordType +'\') AND (Commodity__c = NULL OR Commodity__c = \''
            + input.commodity +'\') AND Process_Type__c = \''
            + input.processType +'\' AND (Process_Type_to_Cancell__c = NULL OR Process_Type_to_Cancell__c = \''
            + input.processTypeToCancell +'\') WITH SECURITY_ENFORCED';
            List<HDT_ProcessCancellationReason__mdt> processCancellationReasons = Database.query(queryCmd);
            for(HDT_ProcessCancellationReason__mdt singleRecord : processCancellationReasons){
                listDescription.add(new HDT_UTL_Option(singleRecord.Process_Cancellation_Reason__c));
            }
            toReturn = new HDT_UTL_ResponseCancellationReason(null,'','OK','Lista ricavata correttamente',JSON.serialize(listDescription));
        }catch(Exception e){
            toReturn = new HDT_UTL_ResponseCancellationReason('KO','ERR-0002: ' +e.getMessage());
        }
        return toReturn;
    }

    public class HDT_UTL_ResponseCancellationReason {
        @InvocableVariable(label='Codice Causale' description='Codice Causale')
        public String causalCode;
        @InvocableVariable(label='Descrizione Causale Annullamento' description='Descrizione Causale Annullamento')
        public String cancellationReason;
        @InvocableVariable(label='Lista delle causali di Annullamento' description='Lista delle causali di Annullamento')
        public String listReasonDescription;
        @InvocableVariable(label='Codice esito chiamata' description='Codice esito')
        public String outcome;
        @InvocableVariable(label='Descrizione esito chiamata' description='Descrizione esito')
        public String outcomeDescription;

        public HDT_UTL_ResponseCancellationReason(String causalCode, String cancellationReason, String outcome, String outcomeDescription,String listReasonDescription){
            this.causalCode = causalCode;
            this.cancellationReason = cancellationReason;
            this.listReasonDescription = listReasonDescription;
            this.outcome = outcome;
            this.outcomeDescription = outcomeDescription;
        }

        public HDT_UTL_ResponseCancellationReason( String outcome, String outcomeDescription){
            this.outcome = outcome;
            this.outcomeDescription = outcomeDescription;
        }
    }

    public class HDT_UTL_RequestCancellationReason{
        @InvocableVariable(label='Case Record' description='Case Record')
        public SObject caseRecord;

        @InvocableVariable(label='User Reason' description='User Reason')
        public String reason;

        @InvocableVariable(label='Record Id' description='Record Id')
        public String recordId;

        @InvocableVariable(label='Method' description='Method')
        public String method;
        
        @InvocableVariable(label='RecordType' description='RecordType')
        public String recordType;

        @InvocableVariable(label='Process Type' description='Process Type')
        public String processType;

        @InvocableVariable(label='Process Type to Cancell' description='Process Type to Cancell')
        public String processTypeToCancell;

        @InvocableVariable(label='Commodity' description='Commodity')
        public String commodity;

        @InvocableVariable(label='CausalCode Process to Cancell' description='CausalCode Process to Cancell')
        public String causalCode;

        @InvocableVariable(label='Process Cancellation Reason' description='Process Cancellation Reason')
        public String processCancellationReason;
    }

    public class HDT_UTL_Option{
        public String label;
        public String value;
        public HDT_UTL_Option(String label){
            this.label = label;
            this.value = label;
        }
    }
}