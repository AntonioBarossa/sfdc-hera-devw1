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

        Datetime dt = Datetime.now();

        MassiveLoaderRequest__c processRequest = new MassiveLoaderRequest__c();
        processRequest.Id = varIdLoaderRequest;
        processRequest.Status__c = 'In Lavorazione';
        processRequest.Phase__c = 'File in elaborazione';
        processRequest.StartDateTime__c = dt;
        processRequest.Description__c = '[1] Lancio processo ------> ora inizio -> ' + String.valueOf(dt.format('HH:mm:ss')) + '\n ';
        HDT_UTL_DatabaseService.updateSObject(processRequest);

    }

   	public Database.QueryLocator start(Database.BatchableContext bc) {
            HDT_QR_Helper qrObj = new HDT_QR_Helper();
            qrObj.setObj('MassiveLoaderRequestItem__c');
            qrObj.setNestedFields(new list<String>{'MassiveLoaderRequest__r.ProcessType__c'});
            qrObj.setFilter('MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' Order by CreatedDate DESC');
			String query =  qrObj.getQeryString();
            //System.debug(LoggingLevel.DEBUG, 'query:  '+query);
			return Database.getQueryLocator(query);
	}

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem execute...');

        HDT_UTL_ProcessExecution cls;
        Type t = Type.forName(selectedProcess.ApexClass__c);
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
            cls.manageCatchException(batchSize, scope, errorMessage);
        }
    }

    public void finish(Database.BatchableContext bc){

        System.debug(LoggingLevel.DEBUG, '>>> HDT_BA_ProcessRequestItem finish ');

        Set<String> apexClassesForBatch = new Set<String>();
        apexClassesForBatch.add('HDT_UTL_ProcessSales');

        switch on selectedProcess.ApexClass__c {
            when 'HDT_UTL_ProcessSales' {
                System.debug(LoggingLevel.DEBUG, '>>> continue with HDT_BA_ProcessSales...');

                Datetime dt = Datetime.now();

                //MassiveLoaderRequest__c oldReq = new MassiveLoaderRequest__c();
                //oldReq.Id = idLoaderRequest;
                MassiveLoaderRequest__c oldReq = [SELECT Id, Description__c FROM MassiveLoaderRequest__c WHERE Id = :idLoaderRequest LIMIT 1];
                oldReq.Description__c = oldReq.Description__c + '\n[2] Creazione Anagrafica -> ora fine ---> ' + String.valueOf(dt.format('HH:mm:ss'));
                update oldReq;

                HDT_BA_ProcessSales processReq = new HDT_BA_ProcessSales(idLoaderRequest, 50, process);
                Database.executeBatch(processReq, 50);
            }
            when 'HDT_UTL_ProcessSetOrderForVas' {
                System.debug(LoggingLevel.DEBUG, '>>> continue with HDT_BA_SetRequestItemForVasOrders...');
                HDT_BA_SetRequestItemForVasOrders setRequestItemForVasOrders = new HDT_BA_SetRequestItemForVasOrders(idLoaderRequest, batchSize, process);
                Database.executeBatch(setRequestItemForVasOrders, batchSize);    
            }
            when else {
                MassiveLoaderRequest__c oldReq = new MassiveLoaderRequest__c();
                oldReq.Id = idLoaderRequest;
                oldReq.Status__c = constantsUtl.MASSIVLOADER_STATUS_CHIUSO;
                oldReq.Phase__c = 'File processato';
                oldReq.EndDateTime__c = Datetime.now();
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

        //if(apexClassesForBatch.contains(selectedProcess.ApexClass__c)){
//
        //} else {
//
//
        //}

    }

}