@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_ProcessOrderCreation implements Database.Batchable<SObject>{

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    private id idLoaderRequest;
    private Integer batchSize;
    private String process;
    
    public HDT_BA_ProcessOrderCreation(Id varIdLoaderRequest, Integer batchSize, String process) {
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

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem execute...');

        HDT_UTL_ProcessExecution cls;
        Type t = Type.forName('HDT_UTL_ProcessOrderCreation');
        cls = (HDT_UTL_ProcessExecution)t.newInstance();
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
            cls.manageCatchException(batchSize, scope, e.getMessage() + ': at line [' + String.valueOf(e.getLineNumber()) + ']');
        }

    }

    public void finish(Database.BatchableContext bc){
        //System.debug('HDT_BA_ProcessRequestItem finish ');
        MassiveLoaderRequest__c oldReq = new MassiveLoaderRequest__c();
        oldReq.Id = idLoaderRequest;
        oldReq.Status__c = constantsUtl.MASSIVLOADER_STATUS_CHIUSO;
        update oldReq;

        // Creazione file RequestItem in Errore 
        List<MassiveLoaderRequestItem__c> listErrorReq = [
            SELECT Id, Name, Data__c, Status__c, StatusDescription__c
            FROM MassiveLoaderRequestItem__c
            WHERE Status__c = 'Errore' AND MassiveLoaderRequest__c = :idLoaderRequest
        ];

        if (listErrorReq!=null && listErrorReq.size()>0) {
            HDT_BA_ErrorRequestItem batch = new HDT_BA_ErrorRequestItem(idLoaderRequest);
            Database.executebatch(batch, 1000);
        }
    }

}