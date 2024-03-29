/*
 * File: HDT_LC_HdtScriptManagementModal.cls
 * Project: HERA
 * File Created: Thursday, 3rd June 2021 5:16:05 pm
 * Author: fdefelice
 * -----
 * Last Modified: Friday, 4th June 2021 7:01:36 pm
 * Modified By: fdefelice
 * -----
 */

public virtual inherited sharing class HDT_LC_HdtScriptManagementModal extends HDT_UTL_FormatTextScript {

    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();

    String childRecordIdentifier='';//Add an Header Identifier to childs sections

    /**
    * @description Get script configuration for a given record
    * @author gabriele.rota@webresults.it | 2021-09-13 
    * @param recordId 
    * @return List<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> 
    **/
    @AuraEnabled
    public static List<HDT_SRV_ScriptManager.HDT_WRP_ScriptConfig> getScriptConfig(String recordId){
        return HDT_SRV_ScriptManager.getScriptConfig(recordId);
    }

    //CB Gestione Script, this method passes to LWC a rich text populated with sections and dinamic data
    @AuraEnabled(cacheable=true)
    public static List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput> getScriptSections(String processName, String recordId, String childRecordIdentifier){
        //test method to show each section in a flow-like modal
        //MUST BE NON-CACHEABLE because it's inputs may not change but content can still change
        //for vocal order, you start from order father but some sections must be looped for each child order
        HDT_LC_HdtScriptManagementModal scriptFormatter = new HDT_LC_HdtScriptManagementModal();
        scriptFormatter.childRecordIdentifier=childRecordIdentifier;
        return scriptFormatter.getScriptTextPages(processName, recordId);
    }

    @AuraEnabled
    public static void saveReitekLink(String recordId, String activityId, String reitekLink){
        //link is saved automatically
        return;
    }

    private List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput> getScriptTextPages(String processName, String recordId){
        List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput> scriptPages= new List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput>();
        if(processName != null && String.isNotBlank(processName)){
            List<ScriptConfig__c> processList = [select Name, contextObject__c, ChildRelationName__c, (Select textScript__c, SectionLabel__c, checkVisibility__c, isChildLoopEvaluated__C from ChildSections__r order by SectionOrder__c asc) from ScriptConfig__c where Name=:processName AND ScriptType__c='Processo' WITH SECURITY_ENFORCED];
            if(!processList.isEmpty()){
                scriptPages= getScriptPagesFromScript(processList[0], recordId, false);
            }
        }
        return scriptPages;
    }

    protected List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput> getScriptPagesFromScript(ScriptConfig__c process, String recordId, Boolean isDecisional){

        List<String> allFieldsToQuery = getAllFieldsToQuery(process);//full list of fields to query
        SObject record = getSobject(recordId, allFieldsToQuery);//this get the generic Sobj
        List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput> listSectionWrappers = new List<HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput>();

        for(ScriptConfig__c section : process.ChildSections__r){
            if(section.isChildLoopEvaluated__C){
                //here the check is run for each child of the context object
                //for each object visible, a section copy is generated
                for(Sobject child : record.getSobjects(process.ChildRelationName__c+'__r') ){
                    if(checkVisibility(section.checkVisibility__c, child)){//We check if the single record section should be visible or not
                        String additionalLabel=String.isBlank(childRecordIdentifier)? '' :
                        ' | '+childRecordIdentifier+ ' : '+String.valueOf(child.get(childRecordIdentifier));
                        listSectionWrappers.add(
                            createSectionWrapper(section, child, additionalLabel)
                        );
                    }
                }
                continue;

            }


            if(checkVisibility(section.checkVisibility__c, record)){//We check if the single record section should be visible or not
                listSectionWrappers.add(
                    createSectionWrapper(section, record)
                );
            }
            else {
                if (isDecisional) {
                    listSectionWrappers.add(
                        createEmptySectionWrapper(section)
                    );
                }
            }
        }
        return listSectionWrappers;
    }

    private HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput createSectionWrapper(ScriptConfig__c section, SObject record){
        return createSectionWrapper(section, record, '');
    }

    private HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput createSectionWrapper(ScriptConfig__c section, SObject record, String additionalLabel){
        return new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput(section, formatText(section.textScript__c, record), additionalLabel);
    }

    private HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput createEmptySectionWrapper(ScriptConfig__c section){
        return new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptOutput(section);
    }

    private List<String> getAllFieldsToQuery(ScriptConfig__c process){
        //getting all fields to be queried from starting object, both for data binding and also for removing sections
        String textToFormat='';

        String childScriptTextToFormat='';//used to store child relationship fields
        
        List<String> conditions = new List<String>();
        List<String> conditionsForChilds = new List<String>();

        for(ScriptConfig__c section : process.ChildSections__r){
            if(section.isChildLoopEvaluated__C){
                childScriptTextToFormat+=section.textScript__c;
                if(String.isNotBlank(section.checkVisibility__c)){
                    conditionsForChilds.add(section.checkVisibility__c);
                }
                continue;
            }
            if(String.isNotBlank(section.checkVisibility__c)){
                conditions.add(section.checkVisibility__c);
            }
            textToFormat +=section.textScript__c;//String with all sections (even those to be eliminated)
        }

        if(String.isNotBlank(childRecordIdentifier) && String.isNotBlank(childScriptTextToFormat)){
            conditionsForChilds.add(childRecordIdentifier+'!=null');//add child record Identifier to fields to be queryed
        }
        

        List<String> allFieldsToQuery = getDataBinded(textToFormat);//get fields name of binding variables
        allFieldsToQuery.addAll(getListConditionFields(conditions));//get fields name of variables in condition statements
        String nestedSoql = buildNestedQuery(childScriptTextToFormat, process.ChildRelationName__c, conditionsForChilds);
        if(STRING.isNotBlank(nestedSoql)){
            allFieldsToQuery.add(nestedSoql);
        }
        return allFieldsToQuery;
    }

    private String buildNestedQuery(String textToExtractFields, String childRelation, List<String> conditionsForChilds){
        List<String> allFieldsToQuery = getDataBinded(textToExtractFields);
        allFieldsToQuery.addAll(getListConditionFields(conditionsForChilds));
        String selectStatement = makeSelectStatement(allFieldsToQuery);

        return STRING.isNotBlank(selectStatement)?
            '( '+selectStatement
                     +' FROM '+childRelation+'__r )' : '';//
    }


    private Set<String> getListConditionFields(List<String> listConditions){
        //get fields name of variables in condition statements
        Set<String> returnSetFieldsToQuery = new Set<String>();
        for(String conditions :listConditions){
            Boolean isOrOperator = conditions.contains('OR');
            String splitOperator = isOrOperator?'OR':'AND';
            List<String> arrayConditions = conditions.split(splitOperator);
            for(String condition : arrayConditions){
                HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition condWrp = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition(condition);
                String field = condWrp.fieldName.toLowerCase();
                returnSetFieldsToQuery.add(field);
            }
        }
        return returnSetFieldsToQuery;
    }


    private Boolean checkVisibility(String conditions, SObject record){
        //this method check if the conditions of a sections are met (both record and condition are defined at run Time)
        if (conditions == null || conditions.trim().equals('')){
            return true;
        }
        
        try{
            Boolean isOrOperator = conditions.contains('OR');
            String splitOperator = isOrOperator?'OR':'AND';

            List<String> arrayConditions = conditions.split(splitOperator);
            return evaluateConditions(arrayConditions, isOrOperator, record);
        }catch(Exception ex){
			return false;
        }
    }

    private Boolean evaluateConditions(List<String> arrayConditions, Boolean isOrOperator, SObject record){
        
        Boolean isAndOperator = !isOrOperator;

        Boolean visibility = isAndOperator?true:false;
        for (String condition : arrayConditions){
            HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition condWrp = new HDT_UTL_ScriptWrappers.HDT_WRP_ScriptCondition(condition);
            String actualFieldValue = getFieldValue(condWrp.fieldName, record);
            Boolean conditionVisibility = condWrp.checkCondition(actualFieldValue);

            if (isOrOperator) {
                visibility = visibility || conditionVisibility;
            }
            else {
                visibility = visibility && conditionVisibility;
            }

            if(!visibility && isAndOperator){
                break;
            }
        }
        return visibility;
    }
}