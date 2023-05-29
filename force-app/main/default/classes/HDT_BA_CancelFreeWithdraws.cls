public with sharing class HDT_BA_CancelFreeWithdraws implements Database.Batchable<Sobject>, Schedulable, Database.Stateful {
    
    // execute Schedulable
    public void execute(SchedulableContext ctx){
        Database.executebatch(this, 200);
    }

    // Batchable<Sobject>
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Iterable(List of record)
        return Database.getQueryLocator([
            SELECT Id, Canceled__c, CreatedDate
            FROM FreeWithdraw__c 
            WHERE Canceled__c = false 
            // AND CALENDAR_YEAR(CreatedDate) <=: DateTime.now().format('yyyy')
            AND CreatedDate <: Datetime.newInstance(DateTime.now().year(), 12, 31)
        ]);

    }

    public void execute(Database.BatchableContext bc, List<FreeWithdraw__c> freeWithdrawList) {
        for(FreeWithdraw__c f : freeWithdrawList){
            f.Canceled__c=true; 
        }
        List<Database.SaveResult> results = Database.update(freeWithdrawList, false);
    }

    public void finish(Database.BatchableContext bc) {
        return;
    }
}
