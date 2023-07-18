public with sharing class HDT_UTL_QualityCall {
    public static final Integer DAYS_TO_WORK = Test.isRunningTest() ? -1 : 50;
    public static final String HANDLE_ACTIVITY = 'Attività gestita';
    public static final String HANDLE_DEADLINE = 'Scadenza gestita';
    public static final Integer ORDER_BATCH_SIZE = 50;
    public static final Date START_DATE = Date.today().addDays(-DAYS_TO_WORK);
    

    public void setLogRecord(List<Database.SaveResult> srList, List<SObject> recordToWork, HDT_SRV_LogService logs, String method){
        this.setLogRecord(srList, recordToWork, logs, method,2);
    }
    
    public void setLogRecord(List<Database.SaveResult> srList, List<SObject> recordToWork, HDT_SRV_LogService logs, String method,Integer attempts){
        attempts--;
        Integer index = 0;
        List<SObject> rObejct = new List<SObject>();
        for(Database.SaveResult sr :srList){
            try{
                if (!sr.isSuccess() || Test.isRunningTest()){
                    SObject obj = recordToWork.get(index);
                    String errorMessage = '';
                    String request = JSON.serialize(obj);
                    Id recordId = obj.get('Id') != null ? (Id)obj.get('Id') : null;
                    for (Database.Error error :  sr.getErrors()){
                        errorMessage += error.getMessage() +  '\n';
                    }
                    if (recordId == null || checkSkipControl(obj,method) || !errorMessage.containsIgnoreCase('unable to obtain exclusive access to this record') || attempts < 0 ){
                        logs.addLog('HDT_BA_QualityCall', method, request, null, errorMessage, recordId, null, null);
                        continue;
                    }
                    rObejct.add(obj);
                }
            }catch(Exception ex){
                System.debug(LoggingLevel.DEBUG, 'HDT_BA_QualityCall - crea Log ' +ex.getMessage());
            }
            index++;
        }
        if (!rObejct.isEmpty()){
            List<Database.SaveResult> newSrList = Database.update(rObejct, false);
            this.setLogRecord(newSrList, rObejct, logs, method + ' - newAttempt',attempts);
        }
    }

    public String checkOrderPhase(String phase){
        if (String.isBlank(phase)){
            return 'BLANK';
        }
        if (HDT_UTL_GestioneScartiSap.skipPhaseManager(phase)){
            return 'NO_CANCEL';
        }
        Map<String,String> phaseResult = new Map<String,String>{
            'completata' => 'NO_CANCEL',
            'in corso caricamento siebel' => 'NO_CANCEL',
            'errore invio a dl/sii' => 'NO_CANCEL',
            'comunicazione verso heroku ok' => 'NO_CANCEL_BILL',
            'comunicazione verso heroku' => 'NO_CANCEL_BILL',
            'caricamento siebel ok' => 'NO_CANCEL_BILL',
            'comunicazione verso motore vas ok' => 'NO_CANCEL_NO_BILL',
            'accettato motore vas' => 'NO_CANCEL_NO_BILL',
            'comunicazione verso motore vas' => 'NO_CANCEL_NO_BILL',
            'annullato' => 'CLOSE_PHASE',
            'voltura rifiutata' => 'CLOSE_PHASE',
            'accettazione voltura' => 'NO_CANCEL'
        };
        return phaseResult.containsKey(phase.toLowerCase()) ? phaseResult.get(phase.toLowerCase()) : 'CANCEL';
    }

    public Boolean notCancellableOrder(Order ord){
        Set<String> annullablePhase = new Set<String>{'Amm. Precheck KO SII','Amm. Precheck OK SII', 'Esito KO da DL', 'Esito KO da SII', 'Ammissibilità KO','Dati discordanti'};
        Boolean switchCancellationEligibility = (ord.ProcessType__c!= null && ord.ProcessType__c.containsIgnoreCase('Switch In')) ? (ord.PhaseStory__c != null && ord.PhaseStory__c.containsIgnoreCase('Ammissibilità OK')) : true;
        return ord.HerokuPracticeCode__c != null && !annullablePhase.contains(ord.Phase__c) && switchCancellationEligibility;
    }

    private Boolean checkSkipControl(SObject obj,String method){
        Boolean skipControl = true;
        //System.Label.EnableQualityCallUpdateControl --> per disattivare la funzione basta valorizzare != 'Y'
        if ('Y'.equalsIgnoreCase(System.Label.EnableQualityCallUpdateControl) && 'update order second batch'.equalsIgnoreCase(method)){
            try{
                String phase =  (String) obj.get('Phase__c');
                String status =  (String) obj.get('Status');
                skipControl = !'Annullato'.equalsIgnoreCase(status) || !'Annullato'.equalsIgnoreCase(phase);
            }catch(Exception e){
                skipControl = true; 
            }
        }
        return skipControl;
    }
}
