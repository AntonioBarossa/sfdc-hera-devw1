@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_CreditCheckSales implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private id idLoaderRequest;
    private Integer batchSize;
    private String process;
    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();

    public HDT_BA_CreditCheckSales(Id varIdLoaderRequest, Integer batchSize, String process) {
        this.idLoaderRequest = varIdLoaderRequest;
        this.batchSize = batchSize;
        this.process = process;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        query += 'SELECT Id, NextStepData__c,MassiveLoaderRequest__r.ProcessType__c ';
        query += 'FROM MassiveLoaderRequestItem__c ';
        query += 'WHERE MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' ';
        query += 'AND Status__c = \'In Lavorazione\' ';
        query += 'Order by CreatedDate DESC';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        HDT_UTL_CreditCheckSales creditCheckSales = new HDT_UTL_CreditCheckSales();
        creditCheckSales.setRequestItemList(scope);
        creditCheckSales.generateWrapperMap();
        creditCheckSales.getRecords();
        creditCheckSales.runCreditCheckSales();
        creditCheckSales.updateItems();

    }

    public void finish(Database.BatchableContext bc){
        //System.debug('HDT_BA_ProcessRequestItem finish ');
        Datetime dt = Datetime.now();
        MassiveLoaderRequest__c oldReq = [SELECT Id, Description__c,Status__c,Phase__c,EndDateTime__c FROM MassiveLoaderRequest__c WHERE Id = :idLoaderRequest LIMIT 1];
        oldReq.Status__c = constantsUtl.MASSIVLOADER_STATUS_CHIUSO;
        oldReq.Phase__c = 'File processato';
        oldReq.EndDateTime__c = Datetime.now();
        oldReq.Description__c = oldReq.Description__c + '\n[6] Credit check  --------> ora fine ---> ' + String.valueOf(dt.format('HH:mm:ss')) + '\n';
        update oldReq;

        // Creazione file RequestItem in Errore 
        List<MassiveLoaderRequestItem__c> listErrorReq = [
            SELECT Id, Name, Data__c, Status__c, StatusDescription__c
            FROM MassiveLoaderRequestItem__c
            WHERE Status__c IN ('Errore', 'Chiuso') AND MassiveLoaderRequest__c = :idLoaderRequest
        ];

        if (listErrorReq!=null && listErrorReq.size()>0) {
            HDT_BA_ErrorRequestItem batch = new HDT_BA_ErrorRequestItem(idLoaderRequest);
            Database.executebatch(batch, 1000);
        }
    }

}