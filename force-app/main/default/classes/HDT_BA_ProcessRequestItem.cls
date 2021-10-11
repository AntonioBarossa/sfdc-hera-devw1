public with sharing class HDT_BA_ProcessRequestItem implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {
    private id idLoaderRequest;

    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();

    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr = new HDT_QR_MassiveLoaderProcess();
    public HDT_BA_ProcessRequestItem(Id varIdLoaderRequest) {
        //System.debug('HDT_BA_ProcessRequestItem : '+varIdLoaderRequest);
        this.idLoaderRequest=varIdLoaderRequest;
        
    }
   	public Database.QueryLocator start(Database.BatchableContext bc) {
            HDT_QR_Helper qrObj=new HDT_QR_Helper();
            qrObj.setObj('MassiveLoaderRequestItem__c');
            qrObj.setNestedFields(new list<String>{'MassiveLoaderRequest__r.ProcessType__c'});
            qrObj.setFilter('MassiveLoaderRequest__c =\''+this.idLoaderRequest+'\' Order by CreatedDate DESC');
			String query =  qrObj.getQeryString();
            //System.debug('query:  '+query);
			return Database.getQueryLocator(query);
	}
    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {
        // System.debug('HDT_BA_ProcessRequestItem execute ' );
        MassiveLoaderRequestItem__c massiveItem=scope.get(0);
        // System.debug('massiveItem:  '+massiveItem);
        // System.debug('ProcessType: '+massiveItem.MassiveLoaderRequest__r.ProcessType__c);
        HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(massiveItem.MassiveLoaderRequest__r.ProcessType__c);
        // System.debug('Apex Class : '+selectedProcess.ApexClass__c);
        Type t = Type.forName(selectedProcess.ApexClass__c);
        HDT_UTL_ProcessExecution cls = (HDT_UTL_ProcessExecution)t.newInstance();
        cls.setMassiveLoaderRequestItem(massiveItem);
        
        try {
            cls.execute();
        } catch (Exception e) {
            massiveItem.Status__c   = 'Errore'                      ;
            massiveItem.StatusDescription__c    = e.getMessage()    ;
            update massiveItem;

        }
    }
    public void finish(Database.BatchableContext bc){
        //System.debug('HDT_BA_ProcessRequestItem finish ');
        MassiveLoaderRequest__c oldReq=new MassiveLoaderRequest__c(id=idLoaderRequest,Status__c=constantsUtl.MASSIVLOADER_STATUS_CHIUSO);
        update oldReq;
        // Creazione file RequestItem in Errore 
        List<MassiveLoaderRequestItem__c> listErrorReq =[SELECT Id,Name,Data__c, Status__c,StatusDescription__c  from MassiveLoaderRequestItem__c WHERE Status__c ='Errore' AND MassiveLoaderRequest__c =:idLoaderRequest ];
        if (listErrorReq!=null && listErrorReq.size()>0) {
            HDT_BA_ErrorRequestItem batch = new HDT_BA_ErrorRequestItem(idLoaderRequest);
            Database.executebatch(batch,1000);
        }
      




        // List<MassiveLoaderRequest__c> listmsr = [SELECT Id FROM MassiveLoaderRequest__c WHERE Status__c=:constantsUtl.MASSIVLOADER_STATUS_INATTESAlAVORAZIONE ORDER BY CreatedDate DESC LIMIT 10];
        // if (listmsr!=null && listmsr.size()>0 ) {
        //     HDT_BA_ProcessRequestItem processReq = new HDT_BA_ProcessRequestItem(listmsr.get(0).id); 
        //     Id batchprocessid = Database.executeBatch(processReq,1);
        // }

        


    }
}
