@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_DiscardDocusignEnvelope implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts{
    
    public void execute(SchedulableContext ctx){
        Database.executebatch(this,1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT id FROM Order WHERE RecordType.DeveloperName = \'HDT_RT_OrderDossier\' AND (Phase__c = \'Annullato\' OR Status = \'Annullato\') AND DiscardDocusignEnvelope__c = true AND SignatureMethod__c = \'OTP Remoto\'');
    }

    public void execute(Database.BatchableContext bc, List<Order> orders){
        Set<Id> orderToCheck = new Set<Id>();
        for (Order o : orders){
            o.DiscardDocusignEnvelope__c = false;
            orderToCheck.add(o.Id);
        }
        HDT_UTL_DatabaseService.updateSObject(orders);
        System.enqueueJob(new HDT_QBL_DiscardDocusignEnvManagement(orderToCheck));
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_DiscardDocusignEnvelope - finished job: ' + a);
    }
}