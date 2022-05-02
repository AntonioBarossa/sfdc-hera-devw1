public with sharing class HDT_BA_ErrorRequestItem implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {

    public static HDT_QR_StaticResource staticResourceQr = new HDT_QR_StaticResource();
    private id idLoaderRequest;
	public Integer errorFileNumber;
    public Integer successFileNumber;
    public String splitCharacter;// = '|';

    public HDT_BA_ErrorRequestItem(Id varIdLoaderRequest) {
        this.idLoaderRequest = varIdLoaderRequest;
        splitCharacter = setSplitCharacter();
    }

    public static String setSplitCharacter(){
        String splitCharacter = HDT_LC_MassiveLoader.getSplitCharacter();
        if(splitCharacter.equalsIgnoreCase('\\|')){
            return '|';
        } else {
            return splitCharacter;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        HDT_QR_Helper qrObj=new HDT_QR_Helper();
        qrObj.setObj('MassiveLoaderRequestItem__c');
        qrObj.setNestedFields(new list<String>{'MassiveLoaderRequest__r.ProcessType__c,MassiveLoaderRequest__r.Name'});
        qrObj.setFilter('MassiveLoaderRequest__c =\'' + this.idLoaderRequest + '\' AND Status__c IN (\'Errore\', \'Chiuso\') Order by CreatedDate DESC');
        String query = qrObj.getQeryString();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<MassiveLoaderRequestItem__c> scope) {
        String reqName;
        String processName;
        String rowSuccess;
        String rowError;
        String headerSuccess;
        String headerError;

        HDT_UTL_MassiveLoaderResult massLoaderResult = new HDT_UTL_MassiveLoaderResult(idLoaderRequest, splitCharacter);

        for(MassiveLoaderRequestItem__c tempReq : scope) {

            if(String.isBlank(processName)){
                processName = tempReq.MassiveLoaderRequest__r.ProcessType__c;
            }

            if(String.isBlank(reqName)){
                reqName = tempReq.MassiveLoaderRequest__r.Name;
            }

            switch on tempReq.Status__c {
                when 'Chiuso' {
                    massLoaderResult.setCurrentSuccessRow(tempReq);
                }	
                when 'Errore' {
                    massLoaderResult.setCurrentErrorRow(tempReq);
                }
            }

        }

        massLoaderResult.generateHeaders(processName, reqName);
        
        if(String.isNotBlank(massLoaderResult.rowError)){
            massLoaderResult.setErrorFile();
            massLoaderResult.generateFile('error');
        }
        
        if(String.isNotBlank(massLoaderResult.rowSuccess)){
            massLoaderResult.setSuccessFile();
            massLoaderResult.generateFile('success');
        }

        massLoaderResult.getLimit();

    }

    public void finish(Database.BatchableContext bc){
        System.debug('HDT_BA_ErrorRequestItem finish ');
    }

}