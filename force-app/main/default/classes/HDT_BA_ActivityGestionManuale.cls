public with sharing class HDT_BA_ActivityGestionManuale implements Database.Batchable<SObject>{

    private static String description = 'Acconto scaduto non pagato da gestire';
    private static String type ='Acconto scaduto non pagato da gestire';
    //private HDT_QR_ActivityCustom qrActivity = new HDT_QR_ActivityCustom();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT id, RecordType.DeveloperName, Phase__c, ExpirationDate__c from case where RecordType.DeveloperName =\'HDT_RT_PianoRateizzazione\' and Phase__c = \'Paperless Generato\' and ExpirationDate__c < TODAY ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Case> cases = (List<Case>) scope;
        Set<Id> casesId = new Set<Id>();
        for(Case c : cases) {
            casesId.add(c.Id);
        }
        List<wrts_prcgvr__Activity__c> existingAct = [SELECT Id, Approved__c, case__c, owner.name, wrts_prcgvr__Description__c, Name FROM wrts_prcgvr__Activity__c WHERE Case__c IN :casesId AND wrts_prcgvr__Description__c=:description];

        Map<String, wrts_prcgvr__Activity__c> mapActivityByCaseId = new Map<String, wrts_prcgvr__Activity__c>();
        if(existingAct.size()>0){
            for(wrts_prcgvr__Activity__c a : existingAct){
                mapActivityByCaseId.put(a.Case__c, a);
            }
        }
        String queryString = 'Select id,wrts_prcgvr__Assignees__c, wrts_prcgvr__Subject__c, wrts_prcgvr__DueDateField__c,Name from wrts_prcgvr__ActivityTemplate__c  where Name = \'Eseguire Gestione Manuale SAP\'';
        String objectName = 'wrts_prcgvr__ActivityTemplate__c';
        List<SObject> listRecord = HDT_QR_GenericQuery.getGenericRecords(queryString, objectName);
        wrts_prcgvr__ActivityTemplate__c template = new wrts_prcgvr__ActivityTemplate__c();
        List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();
        System.debug(LoggingLevel.DEBUG,'existingAct: ' + existingAct.size());
        if(listRecord.size()>0){
            for(Case c : cases){
                if(mapActivityByCaseId.get(c.Id)==null){
                    activities.add(createActivity(c.Id, description, (wrts_prcgvr__ActivityTemplate__c) listRecord[0], type));
                }
            }
            System.debug(LoggingLevel.DEBUG,'activities: ' + activities.size());
            if(activities.size()>0) {
                HDT_UTL_DatabaseService.insertSObject(activities);
            }
        } 

    }

    private static wrts_prcgvr__Activity__c createActivity(String recordId, String description, wrts_prcgvr__ActivityTemplate__c template, String type){
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.wrts_prcgvr__ActivityTemplate__c = template.Id;
        activity.Case__c = recordId;
        activity.CausalError__c = description;
        activity.wrts_prcgvr__Description__c = description;
        activity.Type__c = type;
        return activity;
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Finish HDT_BA_ActivityGestionManuale');
    }

    
}
