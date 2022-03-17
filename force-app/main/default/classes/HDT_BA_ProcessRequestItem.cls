@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_BA_ProcessRequestItem implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private Id idLoaderRequest;
    private Integer batchSize;
    private String process;
    private HDT_MassiveLoaderProcess__mdt selectedProcess;
    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr = new HDT_QR_MassiveLoaderProcess();

    public HDT_BA_ProcessRequestItem(Id varIdLoaderRequest, Integer batchSize, String process) {
        //System.debug(LoggingLevel.DEBUG, 'HDT_BA_ProcessRequestItem : '+varIdLoaderRequest);
        this.idLoaderRequest = varIdLoaderRequest;
        this.batchSize = batchSize;
        this.process = process;

        selectedProcess = massiveLoaderProcessQr.getRecordByName(this.process);
        System.debug(LoggingLevel.DEBUG, '>>> Apex Class: ' + selectedProcess.ApexClass__c);

    }

   	public Database.QueryLocator start(Database.BatchableContext bc) {
            HDT_QR_Helper qrObj = new HDT_QR_Helper();
            qrObj.setObj('MassiveLoaderRequestItem__c');
            qrObj.setNestedFields(new list<String>{'MassiveLoaderRequest__r.ProcessType__c'});
            qrObj.setFilter('MassiveLoaderRequest__c =\'' + this.idLoaderRequest+'\' Order by CreatedDate DESC');
			String query =  qrObj.getQeryString();
            //System.debug(LoggingLevel.DEBUG, 'query:  '+query);
			return Database.getQueryLocator(query);
	}

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem execute...');

        HDT_UTL_ProcessExecution cls;
        Type t = Type.forName(selectedProcess.ApexClass__c);
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

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem finish ');

        Set<String> apexClassesForBatch = new Set<String>();
        apexClassesForBatch.add('HDT_UTL_ProcessSales');

        if(apexClassesForBatch.contains(selectedProcess.ApexClass__c)){
            System.debug(LoggingLevel.DEBUG, '>>> continue with HDT_BA_ProcessSales...');
            HDT_BA_ProcessSales processReq = new HDT_BA_ProcessSales(idLoaderRequest, batchSize, process);
            Database.executeBatch(processReq, batchSize);
        } else {
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

}