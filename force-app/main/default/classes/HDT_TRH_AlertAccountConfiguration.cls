@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_TRH_AlertAccountConfiguration extends HDT_TRH_TriggerHandler {
    
    protected override void afterInsert() {
        handleAlerts();
    }

    protected override void afterUpdate() {
        handleAlerts();
    }

    /**
     * Crea il Case di Modifica Alert e lo invia a SAP.
     */
    private void handleAlerts() {

        HDT_QR_RecordType rtQueryHandler = new HDT_QR_RecordType();
        HDT_QR_AccountContactRelation acrQueryHandler = new HDT_QR_AccountContactRelation();
        HDT_UTL_CreateGenericCase caseUtility = new HDT_UTL_CreateGenericCase();
        Map<String, Object> inputsMap = new Map<String, Object>();
        inputsMap.put('recordTypeId', rtQueryHandler.getRecordTypeIdByName('HDT_RT_AlertDisassociazioneUtenteWeb'));
        inputsMap.put('cluster', 'Modifiche Anagrafiche');
        inputsMap.put('type', 'Modifica Alert');

        Map<String, String> accountContactsMap = new Map<String, String>();
        Map<String, String> accountCompanyMap = new Map<String, String>();
        Set<Id> accountIds = new Set<Id>();

        String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;

        for (AlertAccountConfiguration__c alert : (List<AlertAccountConfiguration__c>) Trigger.new) {
            if (alert.Account__c != null) {
                accountIds.add(alert.Account__c);
            }
        }

        List<AccountContactRelation> relations = acrQueryHandler.getPrimaryContactRelations(accountIds);
        for (AccountContactRelation acr : relations) {
            if (acr.Roles != null && acr.Roles.contains('Titolare')) {
                accountContactsMap.put(acr.AccountId, acr.ContactId);
                accountCompanyMap.put(acr.AccountId, acr.Account.CompanyOwner__c);
            }
        }

        List<Case> alertCases = new List<Case>();
        for (AlertAccountConfiguration__c alert : (List<AlertAccountConfiguration__c>) Trigger.new) {
            // Skippiamo gli alert inizialmente inattivi e senza canali, creati di default dall'lwc sulla service console.
            if (Trigger.isInsert && !alert.IsActive__c && !alert.IsEmailChannelActive__c
                && !alert.IsSmsChannelActive__c && !alert.IsPushChannelActive__c && !alert.IsSolChannelActive__c) {
                continue;
            }

            // In caso di update creiamo il Case solo se il flag di attivazione è stato modificato.
            if (Trigger.isUpdate) {
                AlertAccountConfiguration__c oldAlert = (AlertAccountConfiguration__c) Trigger.oldMap.get(alert.Id);
                if (oldAlert != null && oldAlert.IsActive__c == alert.IsActive__c) {
                    continue;
                }
            }

            inputsMap.put('accountId', alert.Account__c);
            inputsMap.put('contactId', accountContactsMap.get(alert.Account__c));
            inputsMap.put('companyOwner', accountCompanyMap.get(alert.Account__c));
            System.debug(LoggingLevel.DEBUG, 'Creazione Case Modifica Alert: parametri di input: ' + inputsMap);
            Case alertCase = caseUtility.createCase(inputsMap);
            if (alertCase != null) {
                if ( profileName.equalsIgnoreCase('Hera M2M Integration User') ){
                    alertCase.origin='Web';
                }
                alertCase.IsAlertActive__c = alert.IsActive__c;
                alertCase.AlertType__c = transcodeAlertType(alert.AlertType__c);
                alertCases.add(alertCase);
            }
        }

        HDT_UTL_DatabaseService.insertSObject(alertCases);

        // Invio a SAP tramite pclick callout.
        for (Case alertCase : alertCases) {
            alertCase.Phase__c = 'Da Inviare';
        }

        HDT_UTL_DatabaseService.updateSObject(alertCases);
    }


/*     public string getProfileNameByCase(String caseId)
    {
        return [SELECT name FROM Profile 
                     WHERE Id = :[SELECT id, profileId FROM user
                                  WHERE Id = :[SELECT CreatedById FROM case WHERE Id = :caseId][0].CreatedById
                                 ][0].profileId
                ][0].name;
    } */

    /**
     * Transcodifica il tipo di alert. SAP si aspetta solo questi due valori: 'Emissione bolletta' oppure 'Inizio periodo autolettura'
     */
    private String transcodeAlertType(String alertType) {
        if (String.isBlank(alertType)) {
            return '';
        }

        switch on alertType {
            when 'Emissione bolletta/fattura' {
                return 'Emissione bolletta';
            }
            when 'Periodo autolettura' {
                return 'Inizio periodo autolettura';
            }
        }

        return '';
    }

}
