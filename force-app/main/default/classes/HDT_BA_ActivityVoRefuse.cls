public with sharing class HDT_BA_ActivityVoRefuse implements Database.Batchable<sObject> {

    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String numberOfDays = setNumberOfDays();
        Date d = date.today();
        Date endDate;
        endDate = d.addDays(-Integer.valueOf(numberOfDays));
        String query = 'SELECT Id, RequestedCancellationDate__c, CreatedDate, Order__c from wrts_prcgvr__Activity__c where validation__c = null AND Type__c = \'Validazione Vocal Order\' and CreatedDate <= :endDate';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<wrts_prcgvr__Activity__c> scope) {
        List<SObject> sobjToUpdate = new List<SObject>();
        Set<String> recordTypeSet = new Set<String>{'HDT_RT_VAS','HDT_RT_ScontiBonus'};
        Set<Id> parentOrders = new Set<Id>();
        for(wrts_prcgvr__Activity__c act : scope)
        {   
            if(act.Order__c != null)
            {
                parentOrders.add(act.Order__c);
                act.wrts_prcgvr__Status__c = 'Chiusa';
                act.validation__c = 'No';
                sobjToUpdate.add(act);

            }
        }
        List<Order> childOrderToUpdate = [SELECT Id, 
            CancellationReason__c, 
            Phase__c,
            Status,
            ParentOrder__c 
            FROM Order
            WHERE ParentOrder__c 
            IN :parentOrders 
            AND RecordType.DeveloperName NOT IN :recordTypeSet 
            WITH SECURITY_ENFORCED];
        
        for(Order child : childOrderToUpdate)
        {
            child.Phase__c = 'Annullato';
            child.Status = 'Annullato';
            child.CancellationReason__c = 'Registrazione non conforme';

            sobjToUpdate.add(child);
        }
        /*List<wrts_prcgvr__Activity__c> actToUpdate = new List<wrts_prcgvr__Activity__c>();
        List<Order> orderList = new List<Order>();
        for (wrts_prcgvr__Activity__c act : scope) {
            //cancel vendita
            act.Validation__c = 'No';
            actToUpdate.add(act); 
            // cancel quote
            for(Order ord : act.Orders__r) {
                if (act.RequestedCancellationDate__c > date.today() && act.wrts_prcgvr__Status__c != 'Closed') {
                    ord.Phase__c = 'Annullato';
                }
                ord.CancellationReason__c = 'Registrazione non conforme';
                orderList.add(ord);
            }
        }*/
        HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('FinishRequiredForBatch');
    }

    public String setNumberOfDays() {
        List<CS_DaysToExpiration__c> numberOfDays = [SELECT NumberOfDays__c FROM CS_DaysToExpiration__c WHERE Type__c='ValidazioneVO'];
        
        return numberOfDays[0].NumberOfDays__c;
    }
}