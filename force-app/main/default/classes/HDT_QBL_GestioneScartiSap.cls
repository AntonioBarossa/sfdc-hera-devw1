public with sharing class HDT_QBL_GestioneScartiSap implements Queueable{
    
    private Id objectId;
    private Map<String,String> activityToOpenStatoMap;
    private Set<String> activitiesToClose;
    private Map<String,String> activityMapFields;

    public HDT_QBL_GestioneScartiSap(Id objectId, List<HDT_GestioneScartiSap__mdt> rules, Map<String, String> mapActivityField) {
        if (objectId != null){
            this.objectId = objectId;
            this.activityToOpenStatoMap = new Map<String,String>();
            this.activitiesToClose = new Set<String>();
            this.activityMapFields = new Map<String,String>();
            if(mapActivityField!=null) this.activityMapFields = mapActivityField;
            for (HDT_GestioneScartiSap__mdt rule : rules){
                if (rule.CreateActivity__c && String.isNotBlank(rule.Activity__c)){
                    this.activityToOpenStatoMap.put(rule.Activity__c,rule.ActivityInitialStatus__c);
                }
                if (String.isNotBlank(rule.ActivityToClose__c)){
                    this.activitiesToClose.add(rule.ActivityToClose__c);
                }
            }
        }else{
            throw new HDT_QBL_GestioneScartiSapException('E\' necessario valorizzare l\'objectId con l\'Id dell\'Order o del Case che si sta lavorando');
        }
        
    }

    public void execute(QueueableContext context) {
        List<wrts_prcgvr__Activity__c> activitiesToUpsert = new List<wrts_prcgvr__Activity__c>();
        if (!this.activitiesToClose.isEmpty()){
            this.closeActivities(activitiesToUpsert);
        }
        if (!this.activityToOpenStatoMap.isEmpty()){
            this.createActivities(activitiesToUpsert);
        }
        if (!activitiesToUpsert.isEmpty()){
            HDT_UTL_DatabaseService.upsertSObject(activitiesToUpsert);
        }
    }

    private void closeActivities(List<wrts_prcgvr__Activity__c> activitiesToUpdate){
        String endDate = this.activityMapFields.get('DATA_ELABORAZIONE');
        String cmp = this.activityMapFields.get('CMP');
        String utenza = this.activityMapFields.get('UTENZA');
        Date endDateVal = null;
        if(String.isNotBlank(endDate)){
            endDateVal = date.valueOf(endDate);
        }
        Datetime endDatetimeVal = null;
        if(String.isNotBlank(endDate)){
            endDatetimeVal = Datetime.valueOf(endDate);
        }
        for (wrts_prcgvr__Activity__c act : [SELECT Id From wrts_prcgvr__Activity__c WHERE (Order__c = :this.objectId OR Case__c = :this.objectId) AND wrts_prcgvr__IsClosed__c = false AND Type__c IN :this.activitiesToClose]){
            wrts_prcgvr__Activity__c actToAdd = new wrts_prcgvr__Activity__c();
            actToAdd.Id =  act.Id;
            actToAdd.wrts_prcgvr__Status__c ='Chiusa';
            actToAdd.EndDate__c = endDateVal!=null ? endDateVal : null;
            actToAdd.ActivityEndTime__c = endDatetimeVal;
            actToAdd.UserCompany__c = String.isNotBlank(cmp) ? cmp : null;
            actToAdd.ClosedByUsername__c = String.isNotBlank(utenza) ? utenza : null;
            activitiesToUpdate.add(actToAdd);
        }
    }

    private void createActivities(List<wrts_prcgvr__Activity__c> activitiesToInsert){
        for (String templateName : this.activityToOpenStatoMap.keySet()){
            String objectType = HDT_UTL_Scarti.getObjectName(this.objectId);
            wrts_prcgvr__Activity__c newAct = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateName(this.objectId, templateName,objectType);
            if (newAct != null){
                if(templateName.equalsIgnoreCase('Errore Lavorazione SAP')){
                    newAct.wrts_prcgvr__Description__c = this.activityMapFields.get('NOTE_ERR');
                }
                newAct.wrts_prcgvr__Status__c = this.activityToOpenStatoMap.get(templateName);
                activitiesToInsert.add(newAct);
            }
        }
    }

    public class HDT_QBL_GestioneScartiSapException extends Exception{}
}
