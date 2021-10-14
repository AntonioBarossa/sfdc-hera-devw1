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

    //CB Gestione Script, this method passes to LWC a rich text populated with sections and dinamic data
    @AuraEnabled(cacheable=true)
    public static List<HDT_WRP_ScriptOutput> getScriptSections(String processName, String recordId, String childRecordIdentifier){
        //test method to show each section in a flow-like modal
        //MUST BE NON-CACHEABLE because it's inputs may not change but content can still change
        //for vocal order, you start from order father but some sections must be looped for each child order
        HDT_LC_HdtScriptManagementModal scriptFormatter = new HDT_LC_HdtScriptManagementModal();
        scriptFormatter.childRecordIdentifier=childRecordIdentifier;
        return scriptFormatter.getScriptTextPages(processName, recordId);
    }

    @AuraEnabled
    public static void saveReitekLink(String recordId, String activityId, String reitekLink){
        //Temporary mock
        if (String.isBlank(reitekLink)) {
            reitekLink = 'https://herapresfdc.cloudando.com/ctreplay/externalView/search?filter={"filter":{"ecid":"saashrapp|1|123|17"},"sort":{"startTs":-1},"index":0}';
        }

        if (String.isNotBlank(activityId)) {
            wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
            activity.Id = activityId;
            activity.RecordingLink__c = reitekLink;
            update activity;
            //activitySrv.updateRecord(activity);
            //Using update because users are not allowed to edit Actiivity (temporary)
        }
    }

    public class HDT_WRP_ScriptOutput{
        @AuraEnabled public string sectionLabel;
        @AuraEnabled public string sectionText;
        @AuraEnabled public String type;
        @AuraEnabled public Decimal nextSection;
        @AuraEnabled public List<HDT_WRP_ScriptDecision> decisions;
    }

    public class HDT_WRP_ScriptDecision{
        @AuraEnabled public String label;
        @AuraEnabled public Integer targetPage;
    }

    private List<HDT_WRP_ScriptOutput> getScriptTextPages(String processName, String recordId){
        ScriptConfig__c process = [select Name, contextObject__c, ChildRelationName__c, (Select textScript__c, SectionLabel__c, checkVisibility__c, isChildLoopEvaluated__C from ChildSections__r order by SectionOrder__c asc) from ScriptConfig__c where Name=:processName AND ScriptType__c='Processo' WITH SECURITY_ENFORCED LIMIT 1 ];
        return getScriptPagesFromScript(process, recordId);
    }

    protected List<HDT_WRP_ScriptOutput> getScriptPagesFromScript(ScriptConfig__c process, String recordId){

        List<String> allFieldsToQuery = getAllFieldsToQuery(process);//full list of fields to query
        SObject record = getSobject(recordId, allFieldsToQuery);//this get the generic Sobj
        List<HDT_WRP_ScriptOutput> listSectionWrappers = new List<HDT_WRP_ScriptOutput>();

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
        }
        return listSectionWrappers;
    }

    private HDT_WRP_ScriptOutput createSectionWrapper(ScriptConfig__c section, SObject record){
        return createSectionWrapper(section, record, '');
    }

    private HDT_WRP_ScriptOutput createSectionWrapper(ScriptConfig__c section, SObject record, String additionalLabel){
        HDT_WRP_ScriptOutput sectionWrapper = new HDT_WRP_ScriptOutput();
        sectionWrapper.sectionLabel=section.SectionLabel__c+additionalLabel;
        sectionWrapper.sectionText=formatText(section.textScript__c, record);

        if (section.isSet('ScriptType__c')) {
            sectionWrapper.type = (String)section.get('ScriptType__c');
        }

        if (section.isSet('NextSection__c')) {
            sectionWrapper.nextSection = (Decimal)section.get('NextSection__c');
        }

        List<HDT_WRP_ScriptDecision> decisions = new List<HDT_WRP_ScriptDecision>();
        List<Schema.SObjectField> decisionFields = new List<Schema.SObjectField>{
            ScriptConfig__c.LabelOption1__c,
            ScriptConfig__c.LabelOption2__c,
            ScriptConfig__c.LabelOption3__c
        };
        for (Schema.SObjectField decisionField:decisionFields) {
            if (section.isSet(decisionField)) {
                String decision = (String)section.get(decisionField);
                if (String.isNotBlank(decision)) {
                    List<String> decisionSplit = decision.split('::');
                    HDT_WRP_ScriptDecision dec = new HDT_WRP_ScriptDecision();
                    dec.label = decisionSplit[0];
                    dec.targetPage = Integer.valueOf( decisionSplit[1] );
                    decisions.add(dec);
                }
            }
        }
        sectionWrapper.decisions = decisions;

        return sectionWrapper;
    }


    /* private override String formatText(String textScript, String recordId){

    } */

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
                Boolean checkCompare = condition.contains('==');
                String compareOperator = checkCompare? '==' : '!=';
                String field = condition.split(compareOperator)[0].toLowerCase();
                returnSetFieldsToQuery.add(field);
            }
        }
        return returnSetFieldsToQuery;
    }




    private boolean checkVisibility(String conditions, SObject record){
        //this method check if the conditions of a sections are met (both record and condition are defined at run Time)
        if (conditions == null || conditions.trim().equals('')){
            return true;
        }
        
        Boolean isOrOperator = conditions.contains('OR');
        Boolean isAndOperator = !isOrOperator;
        String splitOperator = isOrOperator?'OR':'AND';

        String fieldName, valueToCheck, actualFieldValue;
        List<String> arrayConditions = conditions.split(splitOperator);
        Boolean visibility = isAndOperator?true:false;
        try{
            for(String condition : arrayConditions){
                Boolean checkCompare = condition.contains('==');
                String compareOperator = checkCompare? '==' : '!=';
				
                List<String> arraySingleCondition = condition.split(compareOperator);
                fieldName = arraySingleCondition[0].trim();
                valueToCheck = arraySingleCondition[1].trim();
                actualFieldValue = getFieldValue(fieldName, record);//method to get field value (String converted) from generic sobject
                Boolean conditionVisibility = assertDynamicValues(actualFieldValue, valueToCheck, checkCompare);//this compare those two values

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

        }catch(Exception ex){
			return false;
        }
        return visibility;
    }



    private static Boolean assertDynamicValues(String actualFieldValue, String valueToCheck, Boolean checkEquals){
        //This method dinamically compares two string, it can be used to check if they match or they differ
        //checkEquals set true means that you must check if the two strings matches, if it false you check if the strings differ
        if ('null'.equalsIgnoreCase(valueToCheck)) {//null means "empty string"
            if (String.isBlank(actualFieldValue) == !checkEquals) {
                return false;
            }
        }else if(valueToCheck.equalsIgnoreCase(String.valueOf(actualFieldValue)) == !checkEquals){
            return false;
        }
        return true;
    }

}