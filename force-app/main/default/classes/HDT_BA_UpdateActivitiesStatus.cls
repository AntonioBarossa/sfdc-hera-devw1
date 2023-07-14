public with sharing class HDT_BA_UpdateActivitiesStatus implements Database.Batchable<wrts_prcgvr__Activity__c>, Database.Stateful {
    public Integer counterKo = 0;
    public Integer counterOk = 0;
    Datetime start = null;
    private static HDT_SRV_BatchExecutionKpi srvBatchEx = new HDT_SRV_BatchExecutionKpi();
    BatchExecutionKpiConfiguration__mdt kpiMeta = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_UpdateActivitiesStatus');

    BatchExecutionKpi__c kpiTrack=new BatchExecutionKpi__c();
    public List<wrts_prcgvr__Activity__c> start(Database.BatchableContext bc) {
        System.debug('------ HDT_BA_UpdateActivitiesStatus start');

        //creo record di tracciamento KPI
        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            kpiTrack = srvBatchEx.createRecord(Datetime.now(),'HDT_BA_UpdateActivitiesStatus');
        }

        Date todayDate=date.today();
        List<CS_DaysToExpiration__c> expRecord = [SELECT QueryLimit__c FROM CS_DaysToExpiration__c WHERE Type__c='UpdateActivitiesStatus'];
        Integer queryLimit = expRecord.size() > 0 && !String.isBlank(expRecord[0].QueryLimit__c) ? Integer.valueOf(expRecord[0].QueryLimit__c) : 10000;
        System.debug(LoggingLevel.DEBUG, '>>>>queryLimit: ' + queryLimit);

        return [
            SELECT Id, wrts_prcgvr__Status__c 
            FROM wrts_prcgvr__Activity__c 
            WHERE Type__c IN ('Chiamata inbound','Chiamata outbound', 'Sportello') AND wrts_prcgvr__Status__c IN ('Aperta','In corso','In Progress') AND createdDate <=: todayDate LIMIT :queryLimit
            ];
    }

    public void execute(Database.BatchableContext BC, List<wrts_prcgvr__Activity__c> scope) {
        List<wrts_prcgvr__Activity__c> actToUpdate = new List<wrts_prcgvr__Activity__c>();
        for (wrts_prcgvr__Activity__c activity : scope) {
           activity.wrts_prcgvr__Status__c = 'Chiusa';
           actToUpdate.add(activity);
        }
        if (actToUpdate!=null && actToUpdate.size()>0) {
            List<Database.SaveResult> results = Database.update(actToUpdate, false);
            for (Integer n=0; n<results.size();n++) {
                Database.SaveResult sr = results[n];

                if(sr.isSuccess()){
                    counterOk++;
                }else{
                    counterKo++;
                }
            }
        }
    }   

    public void finish(Database.BatchableContext bc){
        System.debug(' ------ finish batch HDT_BA_UpdateActivitiesStatus');

        if(kpiMeta!=null && kpiMeta.EnableEmailSend__c){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address' LIMIT 1];
            mail.setOrgWideEmailAddressId(owea[0].Id);
            mail.setToAddresses(new String[]{kpiMeta.DesiredEmail__c});
            mail.setSubject('Batch HDT_BA_UpdateActivitiesStatus execution KPI');
            String body='number of records: ' + (counterKo+counterOk) + '\nsuccessful updates: ' + counterOk + '\nunsuccessful updates ' + counterKo ;
            mail.setPlainTextBody (body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            srvBatchEx.updateRecord(kpiTrack.Id,counterOk, counterKo, counterKo + counterOk);
        }

    }
    
}