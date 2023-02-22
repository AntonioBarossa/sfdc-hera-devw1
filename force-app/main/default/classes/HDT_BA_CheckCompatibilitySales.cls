@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_CheckCompatibilitySales implements Database.Batchable<SObject> {

    private id idLoaderRequest;
    private Integer batchSize;
    private String process;
    
    public HDT_BA_CheckCompatibilitySales(Id varIdLoaderRequest, Integer batchSize, String process) {
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
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        HDT_UTL_CheckCompatibilitySales compatibility = new HDT_UTL_CheckCompatibilitySales();
        compatibility.setRequestItemList(scope);
        compatibility.generateWrapperMap();
        compatibility.getRecords();
        compatibility.runCheckCompatibilitySales();
        compatibility.updateItems();

    }

    public void finish(Database.BatchableContext bc){
        System.debug('HDT_BA_CheckCompatibilitySales finish');

        Datetime dt = Datetime.now();

        MassiveLoaderRequest__c oldReq = [SELECT Id, Description__c FROM MassiveLoaderRequest__c WHERE Id = :idLoaderRequest LIMIT 1];
        oldReq.Description__c = oldReq.Description__c + '\n[5] Compatibilità --------> ora fine ---> ' + String.valueOf(dt.format('HH:mm:ss'));
        update oldReq;

        HDT_BA_CreditCheckSales creditCheckSales = new HDT_BA_CreditCheckSales(idLoaderRequest, 1, process);
        Database.executebatch(creditCheckSales, 1);
    }

}