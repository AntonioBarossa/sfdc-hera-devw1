/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 23-05-2022
 * @last modified by  : federico.defelice@webresults.it
**/
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces')
public with sharing class HDT_UTL_ActivityCloseActions {

    private inherited sharing class HDT_WRP_Actions extends HDT_UTL_ActivityTemplate.HDT_WRP_Infos {

        private String phase;
        HDT_WRP_Actions(String phase, String activityType, Boolean isMandatory, String actualPhase){
            super(activityType, isMandatory, actualPhase);
            this.phase = phase;  
        }
        HDT_WRP_Actions(String phase){
            this.phase = phase;
        }
    }

    private inherited sharing class HDT_WRP_Queue implements Queueable{

        Map<Id, HDT_WRP_Actions> actions;
        HDT_WRP_Queue(Map<Id, HDT_WRP_Actions> actions){
            this.actions=actions;
        }
        public void execute(QueueableContext context) {
            HDT_UTL_ActivityTemplate utilsTemplate = new HDT_UTL_ActivityTemplate();
            utilsTemplate.handleNewActivityCreation(this.actions);
        }
    }

    public static void executeOnCloseActions(List<wrts_prcgvr__Activity__c> newTriggerList,  Map<Id,SObject> oldTriggerMap){
        Map<Id, wrts_prcgvr__Activity__c> newTriggerMap = new Map<Id, wrts_prcgvr__Activity__c>(newTriggerList);
        Map<Id, HDT_WRP_Actions> caseToNewActivityType = new Map<Id, HDT_WRP_Actions>();
        List<wrts_prcgvr__Activity__c> activitiesWithCases = getRelatedCases(newTriggerList, oldTriggerMap);
        List<Case> casesToUpdate = new List<Case>();
        if(activitiesWithCases.isEmpty())     return;
        
        for(wrts_prcgvr__Activity__c actWithCase : activitiesWithCases){
            Case actualCase = (Case) actWithCase.getSobject('Case__r');
            wrts_prcgvr__Activity__c currentCaseActivity = newTriggerMap.get(actWithCase.Id);
            HDT_WRP_Actions newAction = getOnCloseActions(actualCase, currentCaseActivity, actWithCase?.wrts_prcgvr__ActivityTemplate__r?.Name);
            if(STRING.isNotBlank(newAction?.phase)){
                actualCase.Phase__c = newAction.phase;
                casesToUpdate.add(actualCase);
            }
            if(STRING.isNotBlank(newAction?.activityType)){
                caseToNewActivityType.put(actualCase.Id,newAction);
            }
        } 

        if(!caseToNewActivityType.isEmpty()){
            System.enqueueJob(new HDT_WRP_Queue(caseToNewActivityType));
            //handleNewActivityCreation(caseToNewActivityType);
        }
        if(!casesToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(casesToUpdate);
        }

    }

    private static List<wrts_prcgvr__Activity__c> getRelatedCases(List<wrts_prcgvr__Activity__c> newTriggerList,  Map<Id,SObject> oldTriggerMap){
        Map<Id,Id> caseToActivity = new Map<Id,Id>();
        for (wrts_prcgvr__Activity__c activity : newTriggerList){
            wrts_prcgvr__Activity__c oldActivity = (wrts_prcgvr__Activity__c)oldTriggerMap.get(activity.Id);
            if ('Chiusa'.equalsIgnoreCase(activity.wrts_prcgvr__Status__c) && !activity.wrts_prcgvr__Status__c.equalsIgnoreCase(oldActivity.wrts_prcgvr__Status__c) && activity.Case__c!= null){
                caseToActivity.put(activity.Case__c, activity.Id);
            }
        }

        if (caseToActivity.isEmpty())    return new List<wrts_prcgvr__Activity__c>();
        return [SELECT Case__r.Id, Case__r.Type, Case__r.Phase__c, wrts_prcgvr__ActivityTemplate__r.Name FROM wrts_prcgvr__Activity__c WHERE Id IN :caseToActivity.values()  WITH Security_Enforced];
    }

    private static HDT_WRP_Actions getOnCloseActions(Case selectedCase, wrts_prcgvr__Activity__c activity, String activityType){
        String approved = activity.Approved__c;
        String caseType = selectedCase.Type;
        activityType=STRING.isNotBlank(activityType)? activityType : ''; 

        if(caseType == 'Formulari Richiesta Sconto')       return new HDT_WRP_Actions('Completata');
        if(caseType == 'Sconti Collettivi Pap')            return new HDT_WRP_Actions('Completata');
        if(caseType == 'Conferimento Centri di Raccolta')  return new HDT_WRP_Actions('Completata');
        
        if(caseType == 'Riduzione Superficie rifiuti spec promiscui') {
            if('Gestione Procedurale'.equalsIgnoreCase(activityType))   return new HDT_WRP_Actions('Completata');
            if(approved.equalsIgnoreCase('si')) return new HDT_WRP_Actions(null, 'Gestione Procedurale', true, selectedCase.Phase__c);//Se gestione SAP non va in completata subito
        if(approved.equalsIgnoreCase('no')) return new HDT_WRP_Actions('Annullato');   
        }
        return null;
    }
}