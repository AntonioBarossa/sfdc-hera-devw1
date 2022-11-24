/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 14-09-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.CyclomaticComplexity , PMD.NcssMethodCount')
public with sharing class HDT_UTL_ActivityCloseActions {

    @TestVisible
    private inherited sharing virtual class HDT_WRP_Actions extends HDT_UTL_ActivityTemplate.HDT_WRP_Infos {

        @TestVisible
        private String phase;
        private String parentSObjectPhase;
        private Sobject sobjToUpdate; 

        HDT_WRP_Actions(){
            return;
        }
        
        HDT_WRP_Actions(String activityType, Boolean isMandatory, String actualPhase){
            super(activityType, isMandatory, actualPhase);
        }
    }

    private inherited sharing class HDT_WRP_CreateActivity extends HDT_WRP_Actions{
        HDT_WRP_CreateActivity(String phase, String activityType, Boolean isMandatory, String actualPhase){
            super(activityType, isMandatory, actualPhase);
            this.phase = phase;
        }
        HDT_WRP_CreateActivity(String activityType, Boolean isMandatory, String actualPhase){
            super(activityType, isMandatory, actualPhase);
        }
    }

    private inherited sharing class HDT_WRP_UpdateSobj extends HDT_WRP_Actions{
        HDT_WRP_UpdateSobj(String phase){
            this.phase=phase;
        }

        HDT_WRP_UpdateSobj(String phase, String parentSObjectPhase){
            this(phase);
            this.parentSObjectPhase = parentSObjectPhase;
        }
    }

    @TestVisible
    private inherited sharing class HDT_WRP_Queue implements Queueable{

        Map<Id, HDT_WRP_Actions> actionsCase;
        Map<Id, HDT_WRP_Actions> actionsOrder;
        
        @TestVisible
        HDT_WRP_Queue(Map<Id, HDT_WRP_Actions> actionsCase, Map<Id, HDT_WRP_Actions> actionsOrder){
            this.actionsCase=actionsCase;
            this.actionsOrder=actionsOrder;
        }
        public void execute(QueueableContext context) {
            HDT_UTL_ActivityTemplate utilsTemplate = new HDT_UTL_ActivityTemplate();
            if(!actionsCase.isEmpty())  utilsTemplate.handleNewActivityCreation(this.actionsCase);
            if(!actionsOrder.isEmpty()) utilsTemplate.handleNewActivityCreation(this.actionsOrder);
        }
    }

    public static void executeOnCloseActions(List<wrts_prcgvr__Activity__c> newTriggerList,  Map<Id,SObject> oldTriggerMap){
        Map<Id, wrts_prcgvr__Activity__c> newTriggerMap = new Map<Id, wrts_prcgvr__Activity__c>(newTriggerList);
        Map<Id, HDT_WRP_Actions> caseToNewActivityType = new Map<Id, HDT_WRP_Actions>();
        Map<Id, HDT_WRP_Actions> orderToNewActivityType = new Map<Id, HDT_WRP_Actions>();
        Map<String,List<wrts_prcgvr__Activity__c>> activitiesWithSObjects = getRelatedSObjects(newTriggerList, oldTriggerMap);
        List<SObject> sObjectToUpdate = new List<SObject>();
        if(activitiesWithSObjects.values().isEmpty())     return;
        
        for(wrts_prcgvr__Activity__c actWithCase : activitiesWithSObjects.get('Related_Cases')){
            Case actualCase = (Case) actWithCase.getSobject('Case__r');
            wrts_prcgvr__Activity__c currentCaseActivity = newTriggerMap.get(actWithCase.Id);
            HDT_WRP_Actions newAction = getOnCloseActions(actualCase, currentCaseActivity, actWithCase?.wrts_prcgvr__ActivityTemplate__r?.Name);
            if(STRING.isNotBlank(newAction?.phase)){
                Case caseUpdate = new Case(Id=actualCase.Id, Phase__c=newAction.phase);
                sObjectToUpdate.add(caseUpdate);
            }
            if(STRING.isNotBlank(newAction?.parentSObjectPhase)){
                Case caseUpdate = new Case(Id=actualCase.RelatedCase__c, Phase__c=newAction.parentSObjectPhase);
                sObjectToUpdate.add(caseUpdate);
            }
            if(STRING.isNotBlank(newAction?.activityType)){
                caseToNewActivityType.put(actualCase.Id,newAction);
            }
        } 

        for(wrts_prcgvr__Activity__c actWithOrder : activitiesWithSObjects.get('Related_Orders')){
            Order actualOrder = (Order) actWithOrder.getSobject('Order__r');
            wrts_prcgvr__Activity__c currentOrderActivity = newTriggerMap.get(actWithOrder.Id);
            HDT_WRP_Actions newAction = getOnCloseActions(actualOrder, currentOrderActivity, actWithOrder?.wrts_prcgvr__ActivityTemplate__r?.Name);
            if(STRING.isNotBlank(newAction?.phase)){
                Order orderUpdate = new Order(Id=actualOrder.Id, Phase__c=newAction.phase);
                sObjectToUpdate.add(orderUpdate);
            }
            if(STRING.isNotBlank(newAction?.parentSObjectPhase)){
                Order orderUpdate = new Order(Id=actualOrder.ParentOrder__c, Phase__c=newAction.parentSObjectPhase);
                sObjectToUpdate.add(orderUpdate);
            }
            if(STRING.isNotBlank(newAction?.activityType)){
                orderToNewActivityType.put(actualOrder.Id,newAction);
            }
        } 

        if(!caseToNewActivityType.isEmpty() || !orderToNewActivityType.isEmpty()){
            System.enqueueJob(new HDT_WRP_Queue(caseToNewActivityType, orderToNewActivityType));
        }
        if(!sObjectToUpdate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(sObjectToUpdate);
        }

    }

    private static Map<String,List<wrts_prcgvr__Activity__c>> getRelatedSObjects(List<wrts_prcgvr__Activity__c> newTriggerList,  Map<Id,SObject> oldTriggerMap){
        List<Id> allActivity = new List<Id>();
        for (wrts_prcgvr__Activity__c activity : newTriggerList){
            wrts_prcgvr__Activity__c oldActivity = (wrts_prcgvr__Activity__c)oldTriggerMap.get(activity.Id);
            if ('Chiusa'.equalsIgnoreCase(activity.wrts_prcgvr__Status__c) && !activity.wrts_prcgvr__Status__c.equalsIgnoreCase(oldActivity.wrts_prcgvr__Status__c)){
                if(activity.Case__c!= null || activity.Order__c!= null)  {
                    allActivity.add(activity.Id);
                }
            }
        }

        if (allActivity.isEmpty())    return new Map<String,List<wrts_prcgvr__Activity__c>>();
        Map<String,List<wrts_prcgvr__Activity__c>> result = new Map<String,List<wrts_prcgvr__Activity__c>>();
        List<wrts_prcgvr__Activity__c> activities = [SELECT Case__r.Id, Case__r.Type, Case__r.Phase__c, Case__r.RelatedCase__c, Case__r.PhaseStory__c, Case__r.Subprocess__c, Case__r.RecordType.DeveloperName,
                                                            Order__r.Id, Order__r.ProcessType__c, Order__r.Phase__c, Order__r.PhaseStory__c, 
                                                            wrts_prcgvr__ActivityTemplate__r.Name 
                                                     FROM wrts_prcgvr__Activity__c 
                                                     WHERE Id IN :allActivity  
                                                     WITH Security_Enforced];
        List<wrts_prcgvr__Activity__c> caseActivities  = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> orderActivities = new List<wrts_prcgvr__Activity__c>();
        
        for(wrts_prcgvr__Activity__c act :activities){
            if(act.Case__r?.Id!=null)  caseActivities.add(act);
            if(act.Order__r?.Id!=null) orderActivities.add(act);
        }

        result.put('Related_Cases',  caseActivities);
        result.put('Related_Orders', orderActivities);
        return result;
    }

    @TestVisible
    private static HDT_WRP_Actions getOnCloseActions(Case selectedCase, wrts_prcgvr__Activity__c activity, String activityType){
        String approved = activity.Approved__c;
        String outcome = activity.ActivityOutcome__c;
        String caseType = selectedCase.Type;
        activityType=STRING.isNotBlank(activityType)? activityType : ''; 

        if(caseType == 'Formulari Richiesta Sconto')       return new HDT_WRP_UpdateSobj('Completata');
        if(caseType == 'Sconti Collettivi Pap')            return new HDT_WRP_UpdateSobj('Completata');
        if(caseType == 'Conferimento Centri di Raccolta')  return new HDT_WRP_UpdateSobj('Completata');
        
        if(caseType == 'Riduz. Superficie rifiuti spec promiscui') {
            if('Gestione Manuale SAP'.equalsIgnoreCase(activityType))   return new HDT_WRP_UpdateSobj('Completata');
            if('si'.equalsIgnoreCase(approved)) return new HDT_WRP_CreateActivity('Gestione Manuale SAP', true, selectedCase.Phase__c);//Se gestione SAP non va in completata subito
            if('no'.equalsIgnoreCase(approved)) return new HDT_WRP_UpdateSobj('Annullato');   
        }
        //START >>> marco.arci@webresults.it

        if( 'HDT_RT_VariazioniTari'.equalsIgnoreCase(selectedCase.RecordType.DeveloperName) ||
            'HDT_RT_DisattivazioniTari'.equalsIgnoreCase(selectedCase.RecordType.DeveloperName)) return tariLogicVarDis(selectedCase, activity);

        //END >>> marco.arci@webresults.it
        if(caseType == 'Gestione Rifiuti' && 'Risposta Ricevuta'.equalsIgnoreCase(activityType)){
            if('si'.equalsIgnoreCase(approved)) return new HDT_WRP_UpdateSobj('Annullato');

            Matcher match = Pattern.compile('\\|\\|([a-zA-Z\\xa0\\s]+)@@Richiesto Annullamento').matcher(selectedCase.PhaseStory__c);
            if('no'.equalsIgnoreCase(approved) && match.find())     return new HDT_WRP_UpdateSobj(match.group(1));
        }
        if(caseType == 'Ambiente annullo richiesta senza appuntamento' && 'Risposta Ricevuta'.equalsIgnoreCase(activityType)){
            if('si'.equalsIgnoreCase(approved))     return new HDT_WRP_UpdateSobj('Completata', 'Annullato');
            if('no'.equalsIgnoreCase(approved))     return new HDT_WRP_UpdateSobj('Annullato');
        }
        return null;
    }
    
	@TestVisible
    private static HDT_WRP_Actions getOnCloseActions(Order selectedOrder, wrts_prcgvr__Activity__c activity, String activityType){
        String approved = activity.Approved__c;
        String activityName=STRING.isNotBlank(activity.Name)? activity.Name : ''; 
        String orderActualPhase=STRING.isNotBlank(selectedOrder.Phase__c)? selectedOrder.Phase__c : '';
        String orderType = selectedOrder.ProcessType__c;
        
        if( 
            'Approvazione Agevolazione'.containsIgnoreCase(activityName)
            && new set<String>{'Modifica Tariffa', 'Modifica Tariffa - Rimozione Agevolazione'}.contains(orderType)
        ){
            if(approved.equalsIgnoreCase('no')) return new HDT_WRP_CreateActivity('Contattare Cliente', false, orderActualPhase);
            if ('In attesa Approvazione'.equalsIgnoreCase(orderActualPhase))   return new HDT_WRP_UpdateSobj('Documentazione Validata');
        }
        return null;
    }

    //START >>> marco.arci@webresults.it
    @TestVisible
    private static HDT_WRP_Actions tariLogicVarDis(Case selectedCase, wrts_prcgvr__Activity__c activity){

        Set<String> subprocessesIntegrati= new Set<String>{
            'Superficie',
            'DOM_Componenti non residenti',
            'NON DOM_ISTAT/Ronchi'
        };
        Set<String> subprocessesNonIntegrati= new Set<String>{
            'DOM_Coabitazioni',
            'DOM_Componenti residenti',
            'Dati catastali',
            'Domiciliato in nucleo residente'
        };
        String outcome = activity.ActivityOutcome__c;
        String caseType = selectedCase.Type;

        if( 'Modifica dati contrattuali'.equalsIgnoreCase(caseType) &&
            'Superficie'.equalsIgnoreCase(selectedCase.Subprocess__c) && 
            'Istruttoria Back Office'.equalsIgnoreCase(activity.Type__c)) {
            if('Positivo'.equalsIgnoreCase(outcome)){
                if(!selectedCase.ModuleFromContributor__c && 'Da Contribuente'.equalsIgnoreCase(selectedCase.RequestSource__c)){    
                    return new HDT_WRP_UpdateSobj('Gestione Documentale');
                }else{
                    return new HDT_WRP_UpdateSobj('Da Inviare');
                }
            }/*else{
                return new HDT_WRP_UpdateSobj('Annullato');
            }*/
        }

        if( 'Modifica post accertamento'.equalsIgnoreCase(caseType) || 
            'Cessazione post accertamento'.equalsIgnoreCase(caseType) ||
            ('Modifica dati contrattuali'.equalsIgnoreCase(caseType) &&
             subprocessesNonIntegrati.contains(selectedCase.Subprocess__c))){
            if('Positivo'.equalsIgnoreCase(outcome)){
                return new HDT_WRP_UpdateSobj('Completata'); //aggiorna la fase del case
            }/*else{
                return new HDT_WRP_UpdateSobj('Annullato');
            }*/
        }

        if( 'Cessazione'.equalsIgnoreCase(caseType) ||
           	('Modifica dati contrattuali'.equalsIgnoreCase(caseType) && 
            ('Superficie'.equalsIgnoreCase(selectedCase.Subprocess__c) && !'Istruttoria Back Office'.equalsIgnoreCase(activity.Type__c)) ||
            subprocessesIntegrati.contains(selectedCase.Subprocess__c))) {
            switch on selectedCase.Phase__c {
                when 'Comunicazione verso Heroku KO'{
                    if('Positivo'.equalsIgnoreCase(outcome)){
                        return new HDT_WRP_UpdateSobj('Da Inviare'); //aggiorna la fase del case
                    }/*else{
                        return new HDT_WRP_UpdateSobj('Annullato');
                    }*/
                }
                when 'Esito KO da SAP'{
                    if('Positivo'.equalsIgnoreCase(outcome)){
                        return new HDT_WRP_UpdateSobj('Da Inviare'); //aggiorna la fase del case
                    }/*else{
                        return new HDT_WRP_UpdateSobj('Annullato');
                    }*/
                }
            }
        }
        return null;
    }

    //END >>> marco.arci@webresults.it
}