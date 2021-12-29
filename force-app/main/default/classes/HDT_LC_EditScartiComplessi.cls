public with sharing class HDT_LC_EditScartiComplessi {
    @AuraEnabled
    public static string getInitData(String recordId){
        Map<String,Object> responseMap = new Map<String,Object>();
        try {
            wrts_prcgvr__Activity__c activity = (wrts_prcgvr__Activity__c)HDT_QR_GenericQuery.getGenericRecords('Id,Case__c, Order__c,Order__r.ParentOrder__c', 'wrts_prcgvr__Activity__c', 'Id =\''+recordId+'\'')[0];
            if (activity.Case__c != null){
                responseMap.put('objectId',recordId);
                responseMap.put('objectType','Case');
            }else if(activity.Order__c != null){
                if (!HDT_UTL_DatabaseService.updateSObject(new Order(Id =  activity.Order__c, Step__c = 3))){
                    throw new AuraHandledException('Impossibile aggiornare l\'ordine.');
                }
                responseMap.put('objectType','Order');
                responseMap.put('object',activity.Order__r);
            }else{
                throw new AuraHandledException('Attività Non Valida');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Non è stata trovata l\'attività richiesta.');
        }
        return JSON.serialize(responseMap);
    }

    @AuraEnabled
    public static String resubmissionPractice(String orderId,String activityId){
        String response;
        Order orderToUpdate = new Order(Id = orderId,Phase__c = 'Comunicazione verso Heroku');
        System.Savepoint sp = Database.setSavePoint();
        try {
            if (!HDT_UTL_DatabaseService.updateSObject(orderToUpdate)){
                response = 'Errore nell\'aggiornamento della fase dell\'ordine.';   
            }else if (!HDT_UTL_Scarti.closeDiscardActivity(activityId)){
                response = 'Impossibile chiudere l\'attività di scarto';
                Database.rollback(sp);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }

    @InvocableMethod(label='Close Discard Activity')
    public static List<String> closeDiscardActivity(List<String> input){
        String response;
        Id activityId = (Id)input[0];
        if (!HDT_UTL_Scarti.closeDiscardActivity(activityId)){
            response = 'Impossibile chiudere l\'attività di scarto';
        }
        return new List<String>{response};
    }
}