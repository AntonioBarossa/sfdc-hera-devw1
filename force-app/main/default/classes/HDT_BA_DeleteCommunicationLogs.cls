public inherited sharing class HDT_BA_DeleteCommunicationLogs implements Database.Batchable<SObject>, Database.Stateful {
    public Integer counterKo = 0;
    public Integer counterOk = 0;
    Datetime start = null;
    private static HDT_SRV_BatchExecutionKpi srvBatchEx = new HDT_SRV_BatchExecutionKpi();
    BatchExecutionKpiConfiguration__mdt kpiMeta = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_DeleteCommunicationLogs');
    BatchExecutionKpi__c kpiTrack=new BatchExecutionKpi__c();

    public List<CommunicationLog__c> start(Database.BatchableContext bc){
        //creo record di tracciamento KPI
        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            kpiTrack = srvBatchEx.createRecord(Datetime.now(),'HDT_BA_DeleteCommunicationLogs');
        }

        //imposto tramite custom setting il delay e la limit sulla query che pesca i record di CommunicationLog__c
        List<CS_DaysToExpiration__c> expRecord = [SELECT NumberOfDays__c, QueryLimit__c FROM CS_DaysToExpiration__c WHERE Type__c='DeleteCommunicationLogs'];
        String numberOfDays = expRecord.size() > 0 && !String.isBlank(expRecord[0].NumberOfDays__c) ? expRecord[0].NumberOfDays__c : '3';
        Integer queryLimit = expRecord.size() > 0 && !String.isBlank(expRecord[0].QueryLimit__c) ? Integer.valueOf(expRecord[0].QueryLimit__c) : 10000;
        Date d = date.today();
        Date endDate = d.addDays(-Integer.valueOf(numberOfDays));
        System.debug(LoggingLevel.DEBUG, '>>>>endDate: ' + endDate);
        System.debug(LoggingLevel.DEBUG, '>>>>queryLimit: ' + queryLimit);

        return [SELECT Id FROM CommunicationLog__c WHERE CreatedDate <: endDate WITH SECURITY_ENFORCED LIMIT :queryLimit];
    }

    public void execute(Database.BatchableContext bc, List<CommunicationLog__c> deleteList){
        List<Database.DeleteResult> deleteResults;
        deleteResults = Database.delete(deleteList, false);

        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            for(Integer n=0; n<deleteResults.size(); n++){
                Database.DeleteResult dr = deleteResults[n];
                
                if (dr.isSuccess()) {
                    counterOk++;
                }
                else{
                    counterKo++;
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc){


        if(kpiMeta!=null && kpiMeta.EnableEmailSend__c){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'HERA Org Wide Address' LIMIT 1];
            mail.setOrgWideEmailAddressId(owea[0].Id);
            mail.setToAddresses(new String[]{kpiMeta.DesiredEmail__c});
            mail.setSubject('Batch HDT_BA_DeleteCommunicationLogs execution KPI');
            String body='number of records: ' + (counterKo+counterOk) + '\nsuccessful deletions: ' + counterOk + '\nunsuccessful deletions ' + counterKo ;
            mail.setPlainTextBody (body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            srvBatchEx.updateRecord(kpiTrack.Id,counterOk, counterKo, counterKo + counterOk);
        }
    }
}