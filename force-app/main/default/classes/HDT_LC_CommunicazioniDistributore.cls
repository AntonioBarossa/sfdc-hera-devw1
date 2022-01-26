public with sharing class HDT_LC_CommunicazioniDistributore {
    @AuraEnabled()
    public static String createActivity(String recordId, string type){
        try {
            List <wrts_prcgvr__Activity__c> listAct=new list <wrts_prcgvr__Activity__c>();
        listAct=HDT_QR_GenericQuery.getGenericRecords('Id, Distributor__c, Account__c, Contact__c, AppointmentDateToConfirm__c', 'wrts_prcgvr__Activity__c', 'Id = \''+String.escapeSingleQuotes(recordId)+'\'');
        //system.debug('@@@lista  ' + listAct[0]);
        Id devRecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_DistributorCommunication').getRecordTypeId();

        wrts_prcgvr__Activity__c actToInsert=new wrts_prcgvr__Activity__c();

        if(listAct!=null && listAct.size()>0){
            if(string.isNotBlank(listAct[0].Id)){
                actToInsert.ParentActivity__c=listAct[0].Id;
            }
            if(string.isNotBlank(listAct[0].Account__c)){
                actToInsert.Account__c=listAct[0].Account__c;
            }
            if(string.isNotBlank(listAct[0].Contact__c)){
                actToInsert.Contact__c=listAct[0].Contact__c;
            }
            if(string.isNotBlank(listAct[0].Distributor__c)){
                actToInsert.Distributor__c=listAct[0].Distributor__c;
            }
            if(listAct[0].AppointmentDateToConfirm__c!=null){
                actToInsert.AppointmentDateToConfirm__c=listAct[0].AppointmentDateToConfirm__c;
            }
            if (String.isNotBlank(devRecordTypeId)) {
                actToInsert.RecordTypeId=devRecordTypeId;
            }
            if (String.isNotBlank(type)) {
                actToInsert.Type__c=type;
            }
            actToInsert.wrts_prcgvr__Status__c='Creata';

        }
        //system.debug('kkkk: '+actToInsert);
        return HDT_UTL_DatabaseService.insertSObject(actToInsert) ? 'ok' : 'ko';

        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
