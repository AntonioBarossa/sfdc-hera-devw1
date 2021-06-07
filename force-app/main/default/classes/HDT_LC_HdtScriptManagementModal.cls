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

public without sharing class HDT_LC_HdtScriptManagementModal extends HDT_UTL_FormatTextScript {


    //CB Gestione Script, this method passes to LWC a rich text populated with sections and dinamic data
    @AuraEnabled
    public static List<HDT_WRP_ScriptOutput> getScriptSections2(String processName, String recordId){
        //test method to show each section in a flow-like modal
        //MUST BE NON-CACHEABLE because it's inputs may not change but content can still change
        //for vocal order, you start from order father but some sections must be looped for each child order
        return new HDT_LC_HdtScriptManagementModal().getScriptTextRich(processName, recordId);
    }

    public class HDT_WRP_ScriptOutput{
        @AuraEnabled public string sectionLabel;
        @AuraEnabled public string sectionText;
    }

    private List<HDT_WRP_ScriptOutput> getScriptTextRich(String processName, String recordId){
        ScriptConfig__c process= [select Name, (Select textScript__c, SectionLabel__c, checkVisibility__c from ChildSections__r order by SectionOrder__c asc) from ScriptConfig__c where Name=:processName AND RecordType.DeveloperName='HDT_RT_Processo' LIMIT 1];

        List<String> allFieldsToQuery = getAllFieldsToQuery(process);//full list of fields to query

        String textToFormat='';
        SObject record = getSobject(recordId, allFieldsToQuery);//this get the generic Sobj

        List<HDT_WRP_ScriptOutput> listSectionWrappers = new List<HDT_WRP_ScriptOutput>();

        for(ScriptConfig__c section : process.ChildSections__r){
            if(checkVisibility(section.checkVisibility__c, record)){//We check if the single record section should be visible or not
                HDT_WRP_ScriptOutput sectionWrapper = new HDT_WRP_ScriptOutput();
                sectionWrapper.sectionLabel=section.SectionLabel__c;
                sectionWrapper.sectionText=formatText(section.textScript__c, recordId, record);
                listSectionWrappers.add(sectionWrapper);
            }            
        }
        return listSectionWrappers;
    }

    //CB Gestione Script, this method passes to LWC a rich text populated with sections and dinamic data
    @AuraEnabled(cacheable=true)
    public static String getScriptSections(String processName, String recordId){
         return new HDT_LC_HdtScriptManagementModal().getScriptText(processName, recordId);
    }


    private String getScriptText(String processName, String recordId){
        ScriptConfig__c process= [select Name, (Select textScript__c, SectionLabel__c, checkVisibility__c from ChildSections__r order by SectionOrder__c asc) from ScriptConfig__c where Name=:processName AND RecordType.DeveloperName='HDT_RT_Processo' LIMIT 1];

        List<String> allFieldsToQuery = getAllFieldsToQuery(process);//full list of fields to query

        String textToFormat='';
        SObject record = getSobject(recordId, allFieldsToQuery);//this get the generic Sobj

        for(ScriptConfig__c section : process.ChildSections__r){
            if(checkVisibility(section.checkVisibility__c, record)){//We check if the single record section should be visible or not
                String sectionLabel = '<<{ globalTag.section__d.'+section.SectionLabel__c.replace(' ', '_')+ ' }>>';
                textToFormat +=sectionLabel+section.textScript__c;
            }            
        }
        String formattedtext= formatText(textToFormat, recordId, record);//we call again the method to bind the final script to values
        return formattedtext;   
    }

    /* private override String formatText(String textScript, String recordId){

    } */

    private List<String> getAllFieldsToQuery(ScriptConfig__c process){
        //getting all fields to be queried from starting object, both for data binding and also for removing sections
        String textToFormat='';
        system.debug(process.ChildSections__r.size());
        
        List<String> conditions = new List<String>();
        for(ScriptConfig__c section : process.ChildSections__r){
            if(String.isNotBlank(section.checkVisibility__c)){
                conditions.add(section.checkVisibility__c);
            }
            String sectionLabel = '<<{ globalTag.section__d.'+section.SectionLabel__c.replace(' ', '_')+ ' }>>';
            //globalTag.section__d.label tell CB to bind the label of the section in bold tags
            textToFormat +=sectionLabel+section.textScript__c;//String with all sections (even those to be eliminated)
        }

        List<String> allFieldsToQuery = getDataBinded(textToFormat);//get fields name of binding variables
        allFieldsToQuery.addAll(getListConditionFields(conditions));//get fields name of variables in condition statements
        return allFieldsToQuery;
    }


    private Set<String> getListConditionFields(List<String> listConditions){
        //get fields name of variables in condition statements
        Set<String> returnSetFieldsToQuery = new Set<String>();
        for(String conditions :listConditions){
            List<String> arrayConditions = conditions.split(';');
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
        String fieldName, valueToCheck, actualFieldValue;
        List<String> arrayConditions = conditions.split(';');
        Boolean visibility=false;
        try{
            for(String condition : arrayConditions){
                Boolean checkCompare = condition.contains('==');
                String compareOperator = checkCompare? '==' : '!=';

                List<String> arraySingleCondition = condition.split(compareOperator);
                fieldName=arraySingleCondition[0];
                valueToCheck=arraySingleCondition[1];
                actualFieldValue=getFieldValue(fieldName, record);//method to get field value (String converted) from generic sobject
                visibility=assertDynamicValues(actualFieldValue, valueToCheck, checkCompare);//this compare those two values
            }

        }catch(Exception ex ){
            System.debug('Exception: Script Section Check Condition - ' + ex.getTypeName() + ': ' + ex.getMessage() + ' -- ' + ex.getCause());
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
