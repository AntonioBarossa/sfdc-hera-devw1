public with sharing class HDT_BA_ProcessRequestItem implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {
    private id idLoaderRequest;
    private static HDT_QR_MassiveLoaderProcess massiveLoaderProcessQr = new HDT_QR_MassiveLoaderProcess();
    public HDT_BA_ProcessRequestItem(Id varIdLoaderRequest) {
        System.debug('HDT_BA_ProcessRequestItem : '+varIdLoaderRequest);
        this.idLoaderRequest=varIdLoaderRequest;
        
    }
   	public Database.QueryLocator start(Database.BatchableContext bc) {
            HDT_QR_Helper qrObj=new HDT_QR_Helper();
            qrObj.setObj('MassiveLoaderRequestItem__c');
            qrObj.setNestedFields(new list<String>{'MassiveLoaderRequest__r.ProcessType__c'});
            qrObj.setFilter('WHERE MassiveLoaderRequest__c ='+  this.idLoaderRequest+'Order by CreatedDate DESC');
			String query =  qrObj.getQeryString();
			return Database.getQueryLocator(query);
	}
    public void execute(Database.BatchableContext BC, List<MassiveLoaderRequestItem__c> scope) {
        System.debug('HDT_BA_ProcessRequestItem execute ' );
        MassiveLoaderRequestItem__c massiveItem=scope.get(0);
        System.debug('ProcessType: '+massiveItem.MassiveLoaderRequest__r.ProcessType__c);
        HDT_MassiveLoaderProcess__mdt selectedProcess = massiveLoaderProcessQr.getRecordByName(massiveItem.MassiveLoaderRequest__r.ProcessType__c);
        System.debug('Apex Class : '+selectedProcess.ApexClass__c);
        Type t = Type.forName(selectedProcess.ApexClass__c);
        HDT_UTL_ProcessExecution cls = (HDT_UTL_ProcessExecution)t.newInstance();
        //cls.execute();

    }
    public void finish(Database.BatchableContext bc){
        System.debug('HDT_BA_ProcessRequestItem finish ');
        


    }
}
