public with sharing class HDT_SRV_EmailMessage {
    public HDT_SRV_EmailMessage() {

    }
    public static void checkIncomingEmails(List<EmailMessage> emailList){
        Map<SObject,Id> mapEmailCase = new Map<SObject,Id>();
        Id parentId;
        String objectName='';
        for(EmailMessage email : emailList){
            parentId = email.parentId != null? email.parentId:'';
            if(String.isNotBlank(parentId)){
                objectName = parentId.getSObjectType().getDescribe().getName();
            }else {
                objectName = '';
            }
            if(String.isNotBlank(objectName)){
                switch on  objectName {
                    when 'Case' {
                        mapEmailCase.put(email, parentId);
                    }
                    when else {
                        //no other case yet
                    }
                }
            }
        }
        if(mapEmailCase.size()>0){
            manageEmailCase(mapEmailCase);
        }
    }

    private static void manageEmailCase(Map<SObject,Id> params){
        List<Id> caseIdList = params.values();
        String idString = String.join( new List<Id>(caseIdList) , '\',\'');
        String queryString = 'SELECT Id, Type, RecordType.DeveloperName,Phase__c FROM Case WHERE Id in (\''+ idString +'\')';
        List<SObject> recordList = HDT_QR_GenericQuery.getGenericRecords(queryString, 'Case');
        Map<Id,Case> mapIdCase = new Map<Id,Case>();
        List<Case> caseToUpdate = new List<Case>();
        for(Case single : (List<Case>)recordList){
            mapIdCase.put(single.Id, single);
        }
        for (SObject emailObj : params.keySet()) {
            EmailMessage email = (EmailMessage) emailObj;
            if(email.Incoming){
                Case caseRecord = mapIdCase.get(email.ParentId);
                if(caseRecord.Type == 'Comunicazione di Fallimento'){
                    caseRecord.Phase__c = 'Risposta Ricevuta';
                }
                caseToUpdate.add(caseRecord);
            }
        }
        if(caseToUpdate.size()>0){
            Boolean result = HDT_UTL_DatabaseService.updateSObject(caseToUpdate);
        }
    }
}
