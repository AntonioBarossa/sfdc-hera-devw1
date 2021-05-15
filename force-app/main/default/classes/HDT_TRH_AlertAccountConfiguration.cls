public with sharing class HDT_TRH_AlertAccountConfiguration extends HDT_TRH_TriggerHandler {
    
    protected override void afterInsert() {
        handleAlerts();
    }

    protected override void afterUpdate() {
        handleAlerts();
    }

    private void handleAlerts() {

        HDT_QR_RecordType rtQueryHandler = new HDT_QR_RecordType();
        HDT_UTL_CreateGenericCase caseUtility = new HDT_UTL_CreateGenericCase();
        Map<String, Object> inputsMap = new Map<String, Object>();
        inputsMap.put('recordTypeId', rtQueryHandler.getRecordTypeIdByName('HDT_RT_AlertDisassociazioneUtenteWeb'));
        inputsMap.put('cluster', 'Modifiche Anagrafiche');
        inputsMap.put('type', 'Modifica Alert');
        inputsMap.put('origin', 'Sportello'); // FIXME: recuperare il canale corretto.

        List<Case> alertCases = new List<Case>();
        for (AlertAccountConfiguration__c alert : (List<AlertAccountConfiguration__c>) Trigger.new) {
            inputsMap.put('accountId', alert.Account__c);
            Case alertCase = caseUtility.createCase(inputsMap);
            if (alertCase != null) {
                alertCase.IsAlertActive__c = alert.IsActive__c;
                alertCase.AlertType__c = alert.AlertType__c;
                alertCases.add(alertCase);
            }
        }

        HDT_UTL_DatabaseService.insertSObject(alertCases);
        // TODO: invio a SAP

    }

}
