public with sharing class HDT_BA_ExpiredOrders implements Database.Batchable<sObject> {
    
    
    //BATCH START
    public Database.QueryLocator start(Database.BatchableContext bc){
        
    }
    
    //BATCH EXECUTE
    public void execute(Database.BatchableContext bc, List<ServiceRequest__c> srList){
        
    }
    
    //BATCH FINISH
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(LoggingLevel.DEBUG, 'HDT_BA_ActivityDispatcher - finished job: ' + a);
    }
    
}
