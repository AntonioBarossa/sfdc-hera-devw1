public with sharing class HDT_LC_VoltureAcceptance {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();

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
            String note = 'accepted'.equals(operation) ? 'Voltura Accettata' : 'Voltura Rifiutata';
            String newPhase = 'accepted'.equals(operation) ? (HDT_LC_OrderDossierWizardActions.checkRequiredDocs( orderQr.getRecordWithDocByOrderId(orderId)[0] ) ? 'Documentazione Validata': 'In attesa validazione') : 'Voltura Rifiutata';
            Order orderToUpdate = new Order(Id = orderId, Phase__c = newPhase, Note__c = note);
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c(Id = activityId, ClosingNote__c = note);
            List<SObject> sobjToUpdate = new List<SObject>();
            sobjToUpdate.add(orderToUpdate);
            sobjToUpdate.add(activity);
            System.Savepoint sp = Database.setSavePoint();
            try {
                
                if (HDT_UTL_Scarti.updateCloseDiscardActivity(activityId) && !HDT_UTL_DatabaseService.updateSObject(sobjToUpdate)){
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
