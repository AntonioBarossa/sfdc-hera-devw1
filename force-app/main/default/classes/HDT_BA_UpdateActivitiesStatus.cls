public with sharing class HDT_BA_UpdateActivitiesStatus implements Database.Batchable<wrts_prcgvr__Activity__c> {

    public List<wrts_prcgvr__Activity__c> start(Database.BatchableContext bc) {
        System.debug('------ HDT_BA_UpdateActivitiesStatus start');
        Date todayDate=date.today();
        return [
            SELECT Id, wrts_prcgvr__Status__c 
            FROM wrts_prcgvr__Activity__c 
            WHERE Type__c IN ('Chiamata inbound','Chiamata outbound', 'Sportello') AND wrts_prcgvr__Status__c IN ('Aperta','In corso') AND createdDate <=: todayDate
            ];
    }

    public void execute(Database.BatchableContext BC, List<wrts_prcgvr__Activity__c> scope) {
        List<wrts_prcgvr__Activity__c> actToUpdate = new List<wrts_prcgvr__Activity__c>();
        for (wrts_prcgvr__Activity__c activity : scope) {
           activity.wrts_prcgvr__Status__c = 'Chiusa';
           actToUpdate.add(activity);
        }
        if (actToUpdate!=null && actToUpdate.size()>0) {
            List<Database.SaveResult> results = Database.update(actToUpdate, false);
        }
    }   

    public void finish(Database.BatchableContext bc){
        System.debug(' ------ finish batch HDT_BA_UpdateActivitiesStatus');
    }
    
}