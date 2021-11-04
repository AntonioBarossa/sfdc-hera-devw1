public with sharing class HDT_BA_ActivityVoRefuse implements Database.Batchable<sObject> {

    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {

        String numberOfDays = setNumberOfDays();
        Date d = date.today();
        Date d2;
        d2 = d.addDays(-Integer.valueOf(numberOfDays));
        String query = 'SELECT Id, CreatedDate, (SELECT Id, CancellationReason__c from Order__r ) from wrts_prcgvr__Activity__c where validation__c = null AND Type__c = \'Validazione Vocal Order\' and CreatedDate <= :d2';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<wrts_prcgvr__Activity__c> scope) {
        List<wrts_prcgvr__Activity__c> actToUpdate = new List<wrts_prcgvr__Activity__c>();
        List<Order> orderList = new List<Order>();
        for (wrts_prcgvr__Activity__c act : scope) {
            //cancel vendita
            act.Validation__c = 'No';
            actToUpdate.add(act); 
            // cancel quote
            for(Order ord : act.Orders__r) {
                ord.CancellationReason__c = 'Registrazione non conforme';
                orderList.add(ord);
            }
        }
        orderSrv.updateRecords(orderList);
        activitySrv.updateRecords(actToUpdate);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('FinishRequiredForBatch');
    }

    public String setNumberOfDays() {
        List<CS_DaysToExpiration__c> numberOfDays = [SELECT NumberOfDays__c FROM CS_DaysToExpiration__c WHERE Type__c='ValidazioneVO'];
        
        return numberOfDays[0].NumberOfDays__c;
    }
}
