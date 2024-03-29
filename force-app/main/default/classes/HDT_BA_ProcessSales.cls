@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_ProcessSales implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
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
        query += 'WHERE MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' ';
        query += 'AND Status__c = \'In Lavorazione\' ';
        query += 'Order by CreatedDate DESC';
        //System.debug('query:  '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        HDT_UTL_ProcessSalesOutboundWs outboundResult = new HDT_UTL_ProcessSalesOutboundWs();
        outboundResult.setRequestItemList(scope, process);
        outboundResult.generateWrapperMap();
        outboundResult.getRecords();
        outboundResult.executeWebService();
        outboundResult.updateItems();

    }

    public void finish(Database.BatchableContext bc){

        System.debug('HDT_BA_ProcessRequestItem finish ');

        Datetime dt = Datetime.now();

        MassiveLoaderRequest__c oldReq = [SELECT Id, Description__c FROM MassiveLoaderRequest__c WHERE Id = :idLoaderRequest LIMIT 1];
        oldReq.Description__c = oldReq.Description__c + '\n[3] Arricchimento dati ---> ora fine ---> ' + String.valueOf(dt.format('HH:mm:ss'));
        update oldReq;

        HDT_BA_ProcessOrderCreation orderCreation = new HDT_BA_ProcessOrderCreation(idLoaderRequest, 25, process);
        Database.executebatch(orderCreation, 25);

    }

}