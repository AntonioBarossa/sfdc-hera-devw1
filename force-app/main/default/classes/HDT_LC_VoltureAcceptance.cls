public with sharing class HDT_LC_VoltureAcceptance {
    @AuraEnabled
    public static string getActivity(String activityId){
        try {
            List<wrts_prcgvr__Activity__c> activities = HDT_QR_GenericQuery.getGenericRecords('Id, isUserActivity__c,Order__c', 'wrts_prcgvr__Activity__c', 'Id =\''+String.escapeSingleQuotes(activityId)+'\'');
            return JSON.serialize(activities[0]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateOrder(String activityId, String orderId, String operation){
        String response = 'OK';
        if (String.isNotEmpty(operation)){
            String newPhase = 'accepted'.equals(operation) ? 'In Attesa Validazione' : 'Voltura Rifiutata';
            Order orderToUpdate = new Order(Id = orderId, Phase__c = newPhase);
            System.Savepoint sp = Database.setSavePoint();
            try {
                
                if (HDT_UTL_Scarti.updateCloseDiscardActivity(activityId) && !HDT_UTL_DatabaseService.updateSObject(orderToUpdate)){
                    response = 'Errore nell\'aggiornamento della fase dell\'ordine.';
                    Database.rollback(sp);
                }
            } catch (Exception e) {
                Database.rollback(sp);
                throw new AuraHandledException(e.getMessage());
            }
        }
        return response;
        
    }
}
