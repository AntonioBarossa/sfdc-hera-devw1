public with sharing class HDT_LC_HighlightsTab {
    @AuraEnabled
    public static Map<String,Object> getKpis(String accountId){
        try {
            return new Map<String,Object>{
                'opportunities' => getOpenOpportunitiesCount(accountId),
                'dossier_open' => getOpenDossiersCount(accountId),
                'dossier_ko' => getKoDossiersCount(accountId)
            };
        } catch (Exception e) {
            return new Map<String,Object>{
                'error' => e.getMessage()
            };
        }
    }

    // NOME FUORVIANTE MA CORRETTO
    private static Integer getOpenOpportunitiesCount(String accountId) {
        // try {
            AggregateResult result = [SELECT COUNT(Id) FROM Case WHERE AccountId = :accountId AND Status != 'Chiuso' AND Cluster__c NOT IN ('Reclami','Preventivi', 'Verifiche') WITH SECURITY_ENFORCED];
            return (Integer) result.get('expr0');
        // } catch (Exception e) {
            // throw e;
        // }
    }
    
    private static Integer getOpenDossiersCount(String accountId) {
        // try {
            AggregateResult caseCount = [SELECT COUNT(Id) FROM Case WHERE AccountId = :accountId AND Status != 'Chiuso' AND ((Cluster__c = 'Reclami' AND Reason__c = 'sospeso per contatto cliente') OR Cluster__c IN ('Preventivi', 'Verifiche')) WITH SECURITY_ENFORCED];
            AggregateResult orderCount = [SELECT COUNT(Id) FROM Order WHERE AccountId = :accountId AND Status != 'Chiuso' WITH SECURITY_ENFORCED];
            return (Integer) caseCount.get('expr0') + (Integer) orderCount.get('expr0');
        // } catch (Exception e) {
            // throw e;
        // }
    }
    
    private static Integer getKoDossiersCount(String accountId) {
        // try {
            AggregateResult caseCount = [SELECT COUNT(Id) FROM Case WHERE AccountId = :accountId AND Status = 'Chiuso' AND Phase__c = 'KO definitivo' AND Cluster__c IN ('Preventivi', 'Verifiche', 'Reclami') WITH SECURITY_ENFORCED];
            AggregateResult orderCount = [SELECT COUNT(Id) FROM Order WHERE AccountId = :accountId AND Status != 'Chiuso' AND Phase__c IN ('Bozza Annullata', 'Annullato', 'Ammissibilità conformità KO', 'Conferma Appuntamento KO', 'Quality Call KO', 'Annullamento dal SII', 'Ripensato', 'Esito KO da DL', 'KO definitivo', 'Preventivo rifiutato', 'Preventivo scaduto', 'KO prodotto VAS') WITH SECURITY_ENFORCED];
            return (Integer) caseCount.get('expr0') + (Integer) orderCount.get('expr0');
        // } catch (Exception e) {
            // throw e;
        // }
    }
}
