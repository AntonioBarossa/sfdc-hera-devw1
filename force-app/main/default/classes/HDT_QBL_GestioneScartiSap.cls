public with sharing class HDT_QBL_GestioneScartiSap implements Queueable{
    
    private Id objectId;
    private Map<String,String> activityToOpenStatoMap;
    private Set<String> activitiesToClose;

    public HDT_QBL_GestioneScartiSap(Id objectId, List<HDT_GestioneScartiSap__mdt> rules) {
        if (objectId != null){
            this.objectId = objectId;
            this.activityToOpenStatoMap = new Map<String,String>();
            this.activitiesToClose = new Set<String>();
            for (HDT_GestioneScartiSap__mdt rule : rules){
                if (rule.CreateActivity__c && String.isNotBlank(rule.Activity__c)){
                    this.activityToOpenStatoMap.put(rule.Activity__c,rule.ActivityInitialStatus__c);
                }
                if (String.isNotBlank(rule.ActivityToClose__c)){
                    this.activitiesToClose.add(rule.ActivityToClose__c);
                }
            }
        }else{
            throw new GestioneScartiSapException('E\' necessario valorizzare l\'objectId con l\'Id dell\'Order o del Case che si sta lavorando');
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
        for (wrts_prcgvr__Activity__c act : [SELECT Id From wrts_prcgvr__Activity__c WHERE (Order__c = :this.objectId OR Case__c = :this.objectId) AND wrts_prcgvr__Status__c != 'Chiusa' AND Type__c IN :this.activitiesToClose]){
            activitiesToUpdate.add(HDT_UTL_Scarti.closeDiscardActivity(act.Id));
        }
    }

    private void createActivities(List<wrts_prcgvr__Activity__c> activitiesToInsert){
        for (String templateName : this.activityToOpenStatoMap.keySet()){
            String objectType = HDT_UTL_Scarti.getObjectName(this.objectId);
            wrts_prcgvr__Activity__c newAct = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateName(this.objectId, templateName,objectType);
            if (newAct != null){
                newAct.wrts_prcgvr__Status__c = this.activityToOpenStatoMap.get(templateName);
                activitiesToInsert.add(newAct);
            }
        }
    }

    public class GestioneScartiSapException extends Exception{}
}
