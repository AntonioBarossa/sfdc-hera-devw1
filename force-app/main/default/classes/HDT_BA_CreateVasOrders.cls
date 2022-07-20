@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_CreateVasOrders implements Database.Batchable<SObject> {

    private Id idLoaderRequest;
    private Integer batchSize;
    private String process;
    private HDT_MassiveLoaderProcess__mdt selectedProcess;
    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr = new HDT_QR_MassiveLoaderProcess();

    public HDT_BA_CreateVasOrders(Id varIdLoaderRequest, Integer batchSize, String process) {
        this.idLoaderRequest = varIdLoaderRequest;
        this.batchSize = batchSize;
        this.process = process;
        selectedProcess = massiveLoaderProcessQr.getRecordByName(this.process);
        System.debug(LoggingLevel.DEBUG, '>>> Apex Class: ' + selectedProcess.ApexClass__c);
    }

   	public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =  '';
        query += 'SELECT Id, Data__c, Status__c, StatusDescription__c, NextStepData__c, RelatedRequestItem__c, ';
        query += '(SELECT Id, Data__c, Status__c, StatusDescription__c FROM RelatedRequestItems__r) ';
        query += 'FROM MassiveLoaderRequestItem__c ';
        query += 'WHERE MassiveLoaderRequest__c = \'' + this.idLoaderRequest + '\'' ;
        query += 'AND VasOrder__c = true ';
        query += 'AND Status__c = \'In Lavorazione\'';
        return Database.getQueryLocator(query);
	}

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_CreateVasOrders execute...');

        HDT_UTL_ProcessExecution cls;
        Type t = Type.forName('HDT_UTL_ProcessOrderCreationForVas');
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
            String errorMessage = e.getMessage() + ': at line [' + String.valueOf(e.getLineNumber()) + '] HDT_UTL_ProcessOrderCreationForVas';
            //cls.manageCatchException(batchSize, scope, errorMessage);
        }
    }

    public void finish(Database.BatchableContext bc){

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem finish ');

        MassiveLoaderRequest__c oldReq = new MassiveLoaderRequest__c();
        oldReq.Id = idLoaderRequest;
        oldReq.Status__c = constantsUtl.MASSIVLOADER_STATUS_CHIUSO;
        oldReq.Phase__c = 'File processato';
        update oldReq;

        // Creazione file RequestItem in Errore 
        List<MassiveLoaderRequestItem__c> listErrorReq = [
            SELECT Id, Name, Data__c, Status__c, StatusDescription__c
            FROM MassiveLoaderRequestItem__c
            WHERE Status__c IN ('Errore', 'Chiuso') AND MassiveLoaderRequest__c = :idLoaderRequest
        ];

        if (listErrorReq != null && listErrorReq.size() > 0) {
            HDT_BA_ErrorRequestItem batch = new HDT_BA_ErrorRequestItem(idLoaderRequest);
            Database.executebatch(batch, 1000);
        }

    }

}