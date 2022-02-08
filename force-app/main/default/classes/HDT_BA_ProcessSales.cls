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
        HDT_QR_Helper qrObj = new HDT_QR_Helper();
        qrObj.setObj('MassiveLoaderRequestItem__c');
        qrObj.setNestedFields(new list<String>{'MassiveLoaderRequest__r.ProcessType__c'});
        qrObj.setFilter('MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' Order by CreatedDate DESC');
        String query =  'SELECT Id, MassiveLoaderRequest__r.ProcessType__c, ';
        //System.debug('query:  '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {
        System.debug('>>>> current account ' + scope);
    }

    public void finish(Database.BatchableContext bc){}

}