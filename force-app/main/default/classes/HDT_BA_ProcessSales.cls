@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_ProcessSales implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {

    private List<Id> accountIdList;
    
    public HDT_BA_ProcessSales(List<Id> accountIdList, Integer batchSize, String process) {
        this.accountIdList = accountIdList;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =  'SELECT Id FROM Account WHERE Id IN : accountIdList';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        System.debug('>>>> current account ' + scope);
    }

    public void finish(Database.BatchableContext bc){}

}