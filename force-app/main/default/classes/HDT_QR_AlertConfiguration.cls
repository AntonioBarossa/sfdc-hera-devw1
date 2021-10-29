public with sharing class HDT_QR_AlertConfiguration {
    
    // Metodo Deprecato
    public List<AlertConfiguration__c> getRecordsByAccountCategory(String accountCategory) {

        List<AlertConfiguration__c> availableAlerts = [
            SELECT 
            Id,
            AlertRule__c, AlertType__c,
            IsActive__c, IsEmailChannelActive__c,
            IsSmsChannelActive__c, IsPushChannelActive__c,
            IsSolChannelActive__c,
            Description__c
            FROM AlertConfiguration__c
            WHERE AccountCategory__c INCLUDES (:accountCategory)
            WITH SECURITY_ENFORCED
        ];

        return availableAlerts;
    }

    public List<Contract> getActiveContracts(String accountId) {
        return [
            SELECT
            Id,
            BillingProfile__r.BillSendingMethod__c
            FROM
            Contract
            WHERE AccountId = :accountId
            AND Status IN ('Activated', 'Attivo')
            WITH SECURITY_ENFORCED
        ];
    }

    /*
    * @Author: Salvatore A. Sarà 20/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public List<AlertConfiguration__c> getRecordsForAccount(String accountId, String accountCategory) {

        List<Contract> activeContracts = getActiveContracts(accountId);
        Set<String> accountSendingMethods = new Set<String>();
        for (Contract c : activeContracts) {
            accountSendingMethods.add(c.BillingProfile__r.BillSendingMethod__c);
        }
        System.debug(LoggingLevel.DEBUG, 'accountSendingMethods: ' + accountSendingMethods);

        List<AlertConfiguration__c> alerts = [
            SELECT 
            Id,
            AlertRule__c, AlertType__c,
            IsActive__c, IsEmailChannelActive__c,
            IsSmsChannelActive__c, IsPushChannelActive__c,
            IsSolChannelActive__c,
            BillSendingMethod__c,
            Description__c
            FROM AlertConfiguration__c
            WHERE AccountCategory__c INCLUDES (:accountCategory)
            WITH SECURITY_ENFORCED
        ];
        System.debug(LoggingLevel.DEBUG, 'alerts: ' + alerts);

        List<AlertConfiguration__c> availableAlerts = new List<AlertConfiguration__c>();
        for (AlertConfiguration__c alertRule : alerts) {
            // Se la regola ha una o più modalità di invio bolletta configurate, la aggiungiamo solo se il cliente ha almeno un contratto attivo con tale modalità di invio.
            if (String.isNotBlank(alertRule.BillSendingMethod__c)) {
                String[] availableMethods = alertRule.BillSendingMethod__c.split(';');
                //System.debug('availableMethods: ' + availableMethods);
                for (String method : availableMethods) {
                    if (accountSendingMethods.contains(method)) {
                        availableAlerts.add(alertRule);
                        break;
                    }
                }
            } else {
                availableAlerts.add(alertRule);
            }
        }

        return availableAlerts;
    }

}
