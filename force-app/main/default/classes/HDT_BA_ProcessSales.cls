@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_ProcessSales implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {

    private id idLoaderRequest;
    private Integer batchSize;
    private String process;
    
    public HDT_BA_ProcessSales(Id varIdLoaderRequest, Integer batchSize, String process) {
        this.idLoaderRequest = varIdLoaderRequest;
        this.batchSize = batchSize;
        this.process = process;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        query += 'SELECT Id, NextStepData__c ';
        query += 'FROM MassiveLoaderRequestItem__c ';
        query += 'WHERE MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' Order by CreatedDate DESC';
        //System.debug('query:  '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        HDT_UTL_ProcessSalesOutboundWs outboundResult = new HDT_UTL_ProcessSalesOutboundWs();
        outboundResult.setRequestItemList(scope);
        outboundResult.getRecords();
        outboundResult.executeWebService();

    }

    public void finish(Database.BatchableContext bc){}

}