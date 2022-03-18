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
        outboundResult.setRequestItemList(scope);
        outboundResult.generateWrapperMap();
        outboundResult.getRecords();
        outboundResult.executeWebService();
        outboundResult.updateItems();

    }

    public void finish(Database.BatchableContext bc){

        System.debug('HDT_BA_ProcessRequestItem finish ');

        //MassiveLoaderRequest__c oldReq = new MassiveLoaderRequest__c();
        //oldReq.Id = idLoaderRequest;
        //oldReq.Status__c = constantsUtl.MASSIVLOADER_STATUS_CHIUSO;
        //update oldReq;

        //// Creazione file RequestItem in Errore 
        //List<MassiveLoaderRequestItem__c> listErrorReq = [
        //    SELECT Id, Name, Data__c, Status__c, StatusDescription__c
        //    FROM MassiveLoaderRequestItem__c
        //    WHERE Status__c = 'Errore' AND MassiveLoaderRequest__c = :idLoaderRequest
        //];

        //if (listErrorReq!=null && listErrorReq.size()>0) {
        //    HDT_BA_ErrorRequestItem batch = new HDT_BA_ErrorRequestItem(idLoaderRequest);
        //    Database.executebatch(batch, 1000);
        //}

        HDT_BA_ProcessOrderCreation orderCreation = new HDT_BA_ProcessOrderCreation(idLoaderRequest, 200, process);
        Database.executebatch(orderCreation, 200);

    }

}