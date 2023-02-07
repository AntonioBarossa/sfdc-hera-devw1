/**
 * @description       : 
 * @author            : federico.defelice@webresults.it
 * @group             : WR
 * @last modified on  : 15-09-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.AvoidDebugStatements, PMD.ForLoopsMustUseBraces')
public inherited sharing class HDT_UTL_ActivityTemplate { 

    private static Integer size = 0;
    private static final Integer MAX_SIZE_SYNC = 3;
    private static final Integer MAX_SIZE_ASYNC = 50;

    private static final Pattern FIELD_PATTERN = Pattern.compile('\\{![\\xa0\\s]?+([A-Za-z0-9_.]+)[\\xa0\\s]?+\\}');
    private List<String> fields;
    @TestVisible
    private String sobjType;
    private static HDT_UTL_Sobject utlSbj = new HDT_UTL_Sobject();
    public HDT_UTL_ActivityTemplate(){
        this.fields= new List<String>{'id'};
    }

    @TestVisible
    private inherited sharing class HDT_WRP_Queue implements Queueable{

        Map<Id, HDT_WRP_Infos> actions;
        @TestVisible
        HDT_WRP_Queue(Map<Id, HDT_WRP_Infos> actions){
            this.actions=actions;
        }
        public void execute(QueueableContext context) {
            HDT_UTL_ActivityTemplate utilsTemplate = new HDT_UTL_ActivityTemplate();
            if(!actions.isEmpty())  HDT_UTL_DatabaseService.insertSObject(utilsTemplate.pclickActivityCreation(this.actions));
            //if(!actionsOrder.isEmpty()) utilsTemplate.handleNewActivityCreation(this.actionsOrder);
        }
    }


    public virtual inherited sharing class HDT_WRP_Infos{

        public String activityType;
        protected String actualPhase;
        protected Boolean isMandatory;

        @TestVisible
        protected HDT_WRP_Infos(String activityType, Boolean isMandatory, String actualPhase){
            this.activityType = activityType;
            this.actualPhase = actualPhase;
            this.isMandatory = isMandatory==null? false : isMandatory;
        }
        protected HDT_WRP_Infos(){
            return;
        }
    }

    public void handlePclickActivityCreation(Map<Id, HDT_WRP_Infos> sobjectToNewActivityType){
        if((size+sobjectToNewActivityType.size()) <= MAX_SIZE_SYNC){
            HDT_UTL_DatabaseService.insertSObject(pclickActivityCreation(sobjectToNewActivityType));
        }else{
            handleAsyncJobs(sobjectToNewActivityType);
        }
    }

    private void handleAsyncJobs(Map<Id, HDT_WRP_Infos> sobjectToNewActivityType){
        Map<Id, HDT_WRP_Infos> mapForAsyncJobs = new Map<Id, HDT_WRP_Infos>();
        Integer count = 0;
        for(Id key : sobjectToNewActivityType.keySet()){
            mapForAsyncJobs.put(key, sobjectToNewActivityType.get(key));
            if(++count > MAX_SIZE_ASYNC && !System.isBatch() && (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0){
                enqueueJob(new HDT_WRP_Queue(new Map<Id, HDT_WRP_Infos>(mapForAsyncJobs)));
                count=0;
                mapForAsyncJobs.clear();
            }
        }
        enqueueJob(new HDT_WRP_Queue(new Map<Id, HDT_WRP_Infos>(mapForAsyncJobs)));
    }

    private void enqueueJob(HDT_WRP_Queue que){
        System.enqueueJob(que);
    }

    private List<wrts_prcgvr__Activity__c> pclickActivityCreation(Map<Id, HDT_WRP_Infos> sobjectToNewActivityType){
        wrts_prcgvr.Interfaces_1_1.IActivityIntegration activityIntegration =
            (wrts_prcgvr.Interfaces_1_1.IActivityIntegration)
            wrts_prcgvr.VersionManager.newClassInstance('ActivityIntegration');

        List<wrts_prcgvr__Activity__c> actsToReturn = new List<wrts_prcgvr__Activity__c>();
        if(sobjectToNewActivityType!= null && sobjectToNewActivityType.isEmpty()) return actsToReturn;
        //validationCheck(sobjectToNewActivityType);//do some validations
        Map<String, wrts_prcgvr__ActivityTemplate__c> templates = getActivityTemplates(sobjectToNewActivityType.values());
        if(templates.isEmpty()) return actsToReturn;
        for(Id sobjId : sobjectToNewActivityType.keySet()){
            HDT_WRP_Infos info = sobjectToNewActivityType.get(sobjId);
            List<wrts_prcgvr__Activity__c> acts = (List<wrts_prcgvr__Activity__c>) activityIntegration.createFromTemplate(templates.get(info.activityType+sobjId.getSobjectType().getDescribe().getName().toLowerCase()).wrts_prcgvr__Code__c, new Map<String,Object>{ 'objectId' => sobjId});
            if(info.isMandatory)    acts[0].wrts_prcgvr__IsRequired__c = true;
            actsToReturn.add(acts[0]);
        }
        return actsToReturn;
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 21-05-2022 
    * @param caseToNewActivityType 
    * @This class gets a map id -> template info (all ids same sobject type) and it creates in bulk activities
    **/
    //public void handleNewActivityCreation(Map<Id, String> sobjectToNewActivityType){
    public void handleNewActivityCreation(Map<Id, HDT_WRP_Infos> sobjectToNewActivityType){
        if(sobjectToNewActivityType!= null && sobjectToNewActivityType.isEmpty()) return;
        validationCheck(sobjectToNewActivityType);//do some validations

        //getActivityTemplate with child relationship ActivityActions from map values
        //create Map templateName -> Template record
        //get all fields to query
        Map<String, wrts_prcgvr__ActivityTemplate__c> templates = getActivityTemplates(sobjectToNewActivityType.values());
        if(templates.isEmpty()) return;

        //make dinamic query
        List<SObject> originalSobjects = utlSbj.getSobjects(sobjectToNewActivityType.keySet(), this.fields, this.sobjType);
        //for each case, create activity, populate fields
        List<wrts_prcgvr__Activity__c> activitiesToInsert =makeActivitiesToInsert(originalSobjects, templates, sobjectToNewActivityType);
        system.debug(LoggingLevel.DEBUG, activitiesToInsert);
        HDT_UTL_DatabaseService.insertSObject(activitiesToInsert);
        return;
    }

    private List<wrts_prcgvr__Activity__c> makeActivitiesToInsert(List<SObject> originalSobjects,Map<String, wrts_prcgvr__ActivityTemplate__c> templates, Map<Id, HDT_WRP_Infos> sobjectToNewActivityType){
        List<wrts_prcgvr__Activity__c> activitiesToInsert = new List<wrts_prcgvr__Activity__c>();
        for(sobject sobj : originalSobjects){
            HDT_WRP_Infos info = sobjectToNewActivityType.get((ID) sobj.get('id'));
            String templateName = info?.activityType;
            wrts_prcgvr__ActivityTemplate__c template = templates.get(templateName);
            
            if(template==null){
                system.debug(LoggingLevel.DEBUG, 'error not found Template Name '+templateName);
                continue;
            }  
            activitiesToInsert.add(createActivity(sobj, template, info));
        }
        return activitiesToInsert;
    }

    private void validationCheck(Map<Id, HDT_WRP_Infos> sobjectToNewActivityType){
        for(id sobjId : sobjectToNewActivityType.keySet()){
            String sobjType=sobjId?.getSobjectType()?.getDescribe()?.getName();
            if(sobjType==null) throw new HDT_UTL_ActivityTemplateException('NULL ID IN MAP');
            if(this.sobjType!=null && sobjType!=this.sobjType)  throw new HDT_UTL_ActivityTemplateException('MIXED SOBJECT IDS IN MAP');
            this.sobjType=sobjType;
        }
    }

    @TestVisible
    private wrts_prcgvr__Activity__c createActivity(sobject sobj, wrts_prcgvr__ActivityTemplate__c template, HDT_WRP_Infos info){
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.wrts_prcgvr__ActivityTemplate__c= template.Id;
        activity.wrts_prcgvr__IsRequired__c=info.isMandatory;//Mandatoria?
        activity.wrts_prcgvr__Phase__c=info.actualPhase;
        activity.wrts_prcgvr__ObjectId__c=(ID) sobj.get('id');
        activity.wrts_prcgvr__Description__c=template.wrts_prcgvr__Subject__c;
        for(wrts_prcgvr__ActivityAction__c action : template.wrts_prcgvr__ActivityActions__r){
            String activityField = getFieldName(action.wrts_prcgvr__Field__c);
            String value = getValue(action.wrts_prcgvr__Value__c, sobj);
            if(STRING.isBlank(activityField) || STRING.isBlank(value))   continue;
            activity.put(activityField, value);
        }
        return activity;
    }

    private Map<String, wrts_prcgvr__ActivityTemplate__c> getActivityTemplates(List<HDT_WRP_Infos> templateInfos){
        Set<String> names = new Set<String>();

        for(HDT_WRP_Infos info : templateInfos)     names.add(info.activityType);

        Map<String, wrts_prcgvr__ActivityTemplate__c> returnMap = new Map<String, wrts_prcgvr__ActivityTemplate__c>();
        List<wrts_prcgvr__ActivityTemplate__c> queryResult = [SELECT Name,
                                    wrts_prcgvr__Assignees__c,
                                    wrts_prcgvr__Code__c,
                                    wrts_prcgvr__DueDateField__c,
                                    wrts_prcgvr__DueDateUnit__c,
                                    wrts_prcgvr__DueDateValue__c,
                                    wrts_prcgvr__FieldsTemplate__c,
                                    wrts_prcgvr__IsRequired__c,
                                    wrts_prcgvr__ObjectType__c,
                                    wrts_prcgvr__Priority__c,
                                    wrts_prcgvr__Subject__c,
                                    (SELECT wrts_prcgvr__Field__c, wrts_prcgvr__Operation__c, wrts_prcgvr__Value__c FROM wrts_prcgvr__ActivityActions__r)
                            FROM wrts_prcgvr__ActivityTemplate__c
                            WHERE Name IN :names
                            //AND wrts_prcgvr__ObjectType__c =:this.sobjType
                            //WITH SECURITY_ENFORCED//Oggetto Tecnico, no security enforced
                        ];
    
        for(wrts_prcgvr__ActivityTemplate__c curTemplate : queryResult){

            String key = curTemplate.Name;
            if(this.sobjType == null){
                key+=curTemplate.wrts_prcgvr__ObjectType__c.toLowerCase();
            } 
            returnMap.put(key, curTemplate);
            for(wrts_prcgvr__ActivityAction__c  action : curTemplate.wrts_prcgvr__ActivityActions__r){
                String fieldName = getFieldName(action.wrts_prcgvr__Value__c);
                if(STRING.isNotBlank(fieldName))    this.fields.add(fieldName);
            }
        }
        return returnMap;
    }

    private String getFieldName(String text){
        if(STRING.isNotBlank(text)){
            Matcher matcher=FIELD_PATTERN.matcher(text);
            if(matcher.find())  return matcher.group(1).toLowerCase().trim();
        }
        return '';
    }

    private String getValue(String text, Sobject sobj){
        if(STRING.isNotBlank(text)){
            Matcher matcher=FIELD_PATTERN.matcher(text);
            if(matcher.find())  return utlSbj.dinamicFieldValue(matcher.group(1).toLowerCase().trim(), sobj);
        }else{
            return '';
        }
        return text;
    }
    
    private inherited sharing class HDT_UTL_Sobject extends HDT_UTL_FormatTextScript{
        private String dinamicFieldValue(String fieldPath, SObject relation){
            String retValue = getFieldValue(fieldPath, relation);
            return retValue=='null'? null : retValue;
        }

        private List<Sobject> getSobjects(Set<Id> recordIds, List<String> fieldsToQuery, String objectName){
            //this method get ids and a list of fields, it returns a generic sobject
            String query = makeSelectStatement(fieldsToQuery);
            List<Sobject> genericSObject = new List<Sobject>();
            if(String.isNotBlank(query)){
                try{
                    genericSObject = (List<SObject>) Database.query(
                        String.escapeSingleQuotes(query) + ' FROM '+String.escapeSingleQuotes(objectName)+' WHERE Id IN :recordIds'
                    );
                }catch(Exception e){
                    throw new HDT_UTL_ActivityTemplateException(
                            'ERRORE DATABASE QUERY, SOQL: # '
                                +query + ' # MESSAGE: '+e.getMessage());
                }
            }
            return genericSObject;
        }
    }
    private class HDT_UTL_ActivityTemplateException extends Exception {}
}