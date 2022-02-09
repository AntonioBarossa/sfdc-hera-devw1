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
        String query = '';
        query += 'SELECT Id, NextStepData__c ';
        query += 'FROM MassiveLoaderRequestItem__c ';
        query += 'WHERE MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' Order by CreatedDate DESC';
        //System.debug('query:  '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        HDT_UTL_ProcessSales.HDT_WRP_NextDataObj obj;
        for(MassiveLoaderRequestItem__c singleItem : scope){
            obj = (HDT_UTL_ProcessSales.HDT_WRP_NextDataObj)JSON.deserialize(singleItem.NextStepData__c, HDT_UTL_ProcessSales.HDT_WRP_NextDataObj.class);
            System.debug('>>>> current item data ' + obj);

            try {
                List<ServicePoint__c> spList = [SELECT Id, MeterStatus__c,Distributor__c,Account__c,ServicePointCode__c FROM ServicePoint__c WHERE Id = :obj.servPointId LIMIT 1];
                HDT_WS_ArrichmentDataEntityResponse serResp = HDT_WS_ArrichmentDataEntityInvoker.callService('', 'IT001E04893470');
                System.debug(serResp);
                List<ServicePoint__c> spListWs = HDT_UTL_ServicePoint.extractDataFromArriccDataServiceWithExistingSp(spList[0], serResp);
                System.debug(spListWs);

                update spListWs;

            } catch (Exception e){
                System.debug('Exception > ' + e.getMessage());
            }
            System.debug('CpuTime > ' + limits.getCpuTime());


        }

    }

    public void finish(Database.BatchableContext bc){}

}