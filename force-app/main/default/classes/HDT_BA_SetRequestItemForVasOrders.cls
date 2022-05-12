@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_SetRequestItemForVasOrders implements Database.Batchable<SObject> {

    private Id idLoaderRequest;
    private Integer batchSize;
    private String process;
    private HDT_MassiveLoaderProcess__mdt selectedProcess;
    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr = new HDT_QR_MassiveLoaderProcess();

    public HDT_BA_SetRequestItemForVasOrders(Id varIdLoaderRequest, Integer batchSize, String process) {
        this.idLoaderRequest = varIdLoaderRequest;
        this.batchSize = batchSize;
        this.process = process;
        selectedProcess = massiveLoaderProcessQr.getRecordByName(this.process);
        System.debug(LoggingLevel.DEBUG, '>>> Apex Class: ' + selectedProcess.ApexClass__c);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =  '';
        query += 'SELECT Id, Data__c, NextStepData__c, RelatedRequestItem__c ';
        query += 'FROM MassiveLoaderRequestItem__c ';
        query += 'WHERE MassiveLoaderRequest__c = \'' + this.idLoaderRequest + '\'' ;
        query += 'AND Status__c = \'In Lavorazione\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_SetRequestItemForVasOrders execute...');

        HDT_UTL_ProcessExecution cls;
        Type t = Type.forName('HDT_UTL_ProcessSetChunkOrderForVas');
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
            String errorMessage = e.getMessage() + ': at line [' + String.valueOf(e.getLineNumber()) + '] ' + selectedProcess.ApexClass__c;
            //cls.manageCatchException(batchSize, scope, errorMessage);
        }
    }

    public void finish(Database.BatchableContext bc){

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem finish ');

        HDT_BA_CreateVasOrders vasOrderCreation = new HDT_BA_CreateVasOrders(idLoaderRequest, 1, process);
        Database.executebatch(vasOrderCreation, 1);

    }

}