public with sharing class HDT_UTL_QualityCall {
    public static final Integer DAYS_TO_WORK = Test.isRunningTest() ? 0 : 50;
    public static final String HANDLE_ACTIVITY = 'Attività gestita';
    public static final String HANDLE_DEADLINE = 'Scadenza gestita';
    public static final Integer ORDER_BATCH_SIZE = 100;
    public static final Date START_DATE = Date.today().addDays(-DAYS_TO_WORK);
    

    public void setLogRecord(List<Database.SaveResult> srList, List<SObject> recordToWork, HDT_SRV_LogService logs, String method){
        Integer index = 0;
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
                    logs.addLog('HDT_BA_QualityCall', method, request, null, errorMessage, recordId, null, null);
                }  
            }catch(Exception ex){
                System.debug(LoggingLevel.DEBUG, 'HDT_BA_QualityCall - crea Log ' +ex.getMessage());
            }
            index++;
        }
    }

    public String checkOrderPhase(String phase){
        if (String.isBlank(phase)){
            return 'BLANK';
        }
        Map<String,String> phaseResult = new Map<String,String>{
            'completata' => 'NO_CANCEL',
            'errore lavorazione sap' => 'NO_CANCEL',
            'errore tecnico invio a sap' => 'NO_CANCEL',
            'flusso bloccato in assenza del precedente	' => 'NO_CANCEL',
            'comunicazione verso heroku ok' => 'NO_CANCEL_BILL',
            'comunicazione verso heroku' => 'NO_CANCEL_BILL',
            'caricamento siebel ok' => 'NO_CANCEL_BILL',
            'comunicazione verso motore vas ok' => 'NO_CANCEL_NO_BILL',
            'accettato motore vas' => 'NO_CANCEL_NO_BILL',
            'comunicazione verso motore vas' => 'NO_CANCEL_NO_BILL',
            'annullato' => 'CLOSE_PHASE',
            'voltura rifiutata' => 'CLOSE_PHASE'
        };
        return phaseResult.containsKey(phase.toLowerCase()) ? phaseResult.get(phase.toLowerCase()) : 'CANCEL';
    }

    public Boolean notCancellableOrder(Order ord){
        Set<String> annullablePhase = new Set<String>{'Amm. Precheck KO SII','Amm. Precheck OK SII', 'Esito KO da DL', 'Esito KO da SII', 'Ammissibilità KO','Dati discordanti'};
        Boolean switchCancellationEligibility = (ord.ProcessType__c!= null && ord.ProcessType__c.containsIgnoreCase('Switch In')) ? (ord.PhaseStory__c != null && ord.PhaseStory__c.containsIgnoreCase('Ammissibilità OK')) : true;
        return ord.HerokuPracticeCode__c != null && !annullablePhase.contains(ord.Phase__c) && switchCancellationEligibility;
    }
}
