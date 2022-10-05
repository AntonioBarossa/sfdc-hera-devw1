public with sharing class HDT_BA_DeleteServicePoints implements Database.Batchable<SObject>, Database.Stateful{
    
    public Integer counterKo = 0;
    public Integer counterOk = 0;
    Datetime start = null;
    private static HDT_SRV_BatchExecutionKpi srvBatchEx = new HDT_SRV_BatchExecutionKpi();
    BatchExecutionKpiConfiguration__mdt kpiMeta = BatchExecutionKpiConfiguration__mdt.getInstance('HDT_BA_DeleteServicePoints');
    BatchExecutionKpi__c kpiTrack=new BatchExecutionKpi__c();
    /*  
        Start{
        Query record da processare
        crea record di KPI
        }

        Execute{
        200 alla volta
        Esecuzione batch
        aggiornamento counter
        }

        Finish{
        aggiornamento record con ok/ko e data fine
        }
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            kpiTrack = srvBatchEx.createRecord(Datetime.now(),'HDT_BA_DeleteServicePoints');
        }
        String queryString = 'SELECT Id FROM ServicePoint__C where SAPImplantCode__c = null and CommoditySector__c = \'Ambiente\' and createdDate <= LAST_N_DAYS:' + Label.HDT_DeleteServicePointDays;
        System.debug(logginglevel.DEBUG, '>>> QUERY: ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<ServicePoint__c> deleteList){
        
        System.debug(logginglevel.DEBUG, '>>> EXECUTE');
        System.debug(logginglevel.DEBUG, '>>> delete: ' + deletelist.size());

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
        //BatchExecutionKpiConfiguration__mdt kpiMeta = [SELECT DesiredEmail__c,EnableEmailSend__c, EnableTracking__c  FROM BatchExecutionKpiConfiguration__mdt WHERE BatchName__c='HDT_BA_DeleteServicePoints' limit 1];
        if(kpiMeta!=null && kpiMeta.EnableEmailSend__c){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            list <EmailSetting__mdt> email=[SELECT DeveloperName, Email__c FROM EmailSetting__mdt WHERE DeveloperName='Elaborazione_Archivio_FUB' limit 1];
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress LIMIT 1];
            mail.setOrgWideEmailAddressId(owea[0].Id);
            mail.setToAddresses(new String[]{kpiMeta.DesiredEmail__c});
            mail.setSubject('Batch HDT_BA_DeleteServicePoints execution KPI');
            String body='number of records: ' + (counterKo+counterOk) + '\nsuccessful deletions: ' + counterOk + '\nunsuccessful deletions ' + counterKo ;
            mail.setPlainTextBody (body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }

        if(kpiMeta!=null && kpiMeta.EnableTracking__c){
            srvBatchEx.updateRecord(kpiTrack.Id,counterOk, counterKo, counterKo + counterOk);
            System.debug('£££ '+ (Datetime.now().getTime() -start.getTime())/60000);
        }
    }
}