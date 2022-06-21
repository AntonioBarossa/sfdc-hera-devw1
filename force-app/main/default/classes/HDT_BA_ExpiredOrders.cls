@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_BA_ExpiredOrders implements Database.Batchable<sObject> , Schedulable {

    public void execute(SchedulableContext ctx){
        Database.executebatch(this,100);
    }

    //BATCH START
    
    //TODO: SOSTITUIRE SEND DATE CON DocusignExpirationDate__c --> Fatto
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date todayDate = Date.today();
        Set<String> recordTypeSet = new Set<String>{'HDT_RT_VAS','HDT_RT_ScontiBonus'};
        return Database.getQueryLocator('SELECT Id, Status, ParentOrder__c, ParentOrder__r.DocusignExpirationDate__c, Phase__c, CancellationReason__c FROM Order WHERE  (ParentOrder__r.DocusignExpirationDate__c != null AND ParentOrder__r.DocusignExpirationDate__c < :todayDate) AND ParentOrder__r.Phase__c NOT IN (\'Documentazione Gestita\') AND Phase__c NOT IN (\'Completata\', \'Annullato\') AND RecordType.DeveloperName NOT IN :recordTypeSet');
    }
    
    //BATCH EXECUTE
    public void execute(Database.BatchableContext bc, List<Order> ordersToNullify){
        
        for(Order myOrder : ordersToNullify){
            myOrder.Phase__c = 'Annullato';
            myOrder.Status = 'Annullato';
            myOrder.CancellationReason__c = 'Annullato per no conferma cliente';
        }
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredOrders - Aggiorno Order Record: ' + ordersToNullify.size());
        
        HDT_UTL_DatabaseService.updateSObject(ordersToNullify);
    }
    
    //BATCH FINISH
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ExpiredOrders - finished job: ' + a);
    }
    
}
