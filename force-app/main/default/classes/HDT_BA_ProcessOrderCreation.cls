@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_ProcessOrderCreation implements Database.Batchable<SObject>{

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    private id idLoaderRequest;
    private Integer batchSize;
    private String process;
    private String orderCreationClass = 'HDT_UTL_ProcessOrderCreation';
    
    public HDT_BA_ProcessOrderCreation(Id varIdLoaderRequest, Integer batchSize, String process) {
        this.idLoaderRequest = varIdLoaderRequest;
        this.batchSize = batchSize;
        this.process = process;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        query += 'SELECT Id, Data__c, NextStepData__c, Status__c, StatusDescription__c ';
        query += 'FROM MassiveLoaderRequestItem__c ';
        query += 'WHERE MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' ';
        query += 'AND Status__c = \'In Lavorazione\' ';
        query += 'Order by CreatedDate DESC';
        //System.debug('query:  '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem execute...');

        HDT_UTL_ProcessExecution cls;
        Type t = Type.forName(orderCreationClass);
        cls = (HDT_UTL_ProcessExecution)t.newInstance();
        cls.setRequestId(this.idLoaderRequest);
        cls.setProcess(process);
        cls.setMassiveLoaderRequestItemList(scope);
        
        try {
            cls.execute();
        } catch (HDT_UTL_ProcessExecution.HDT_WRP_ProcessEntitiesException e) {
            System.debug(LoggingLevel.DEBUG, '>>> HDT_WRP_ProcessEntitiesException');
            System.debug(LoggingLevel.DEBUG, e.Message);
            //update massiveItem;
        } catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Standard Exception: ' + e.getMessage());
            cls.manageCatchException(batchSize, scope, e.getMessage() + ': at line [' + String.valueOf(e.getLineNumber()) + '] - ' + orderCreationClass);
        }

    }

    public void finish(Database.BatchableContext bc){
        System.debug('HDT_BA_ProcessOrderCreation finish ');

        Datetime dt = Datetime.now();

        MassiveLoaderRequest__c oldReq = [SELECT Id, Description__c FROM MassiveLoaderRequest__c WHERE Id = :idLoaderRequest LIMIT 1];
        oldReq.Description__c = oldReq.Description__c + '\n[4] Creazione ordini -----> ora fine ---> ' + String.valueOf(dt.format('HH:mm:ss'));
        update oldReq;
        
        //Marco Ficorella 18/11/2022 - aumentato size post ottimizzazione metodi a valle
        //batchSize = 20;
        batchSize = 1;
        HDT_BA_CheckCompatibilitySales checkCompatibilitySales = new HDT_BA_CheckCompatibilitySales(idLoaderRequest, batchSize, process);
        Database.executebatch(checkCompatibilitySales, batchSize);

    }

}