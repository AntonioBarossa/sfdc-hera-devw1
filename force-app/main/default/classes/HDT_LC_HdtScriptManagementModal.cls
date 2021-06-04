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

    @AuraEnabled(cacheable=true)
    public static String getScriptSections(String processName, String recordId){
         return new HDT_LC_HdtScriptManagementModal().getScriptText(processName, recordId);
    }


    private String getScriptText(String processName, String recordId){
        ScriptConfig__c process= [select Name, (Select textScript__c, SectionLabel__c, checkVisibility__c from ChildSections__r order by SectionOrder__c asc) from ScriptConfig__c where Name=:processName AND RecordType.DeveloperName='HDT_RT_Processo' LIMIT 1];

        
        List<String> allFieldsToQuery = getAllFieldsToQuery(process);
        String textToFormat='';
        SObject record = getSobject(recordId, allFieldsToQuery);

        for(ScriptConfig__c section : process.ChildSections__r){
            if(checkVisibility(section.checkVisibility__c, record)){
                String sectionLabel = '<<{ globalTag.section__d.'+section.SectionLabel__c.replace(' ', '_')+ ' }>>';
                textToFormat +=sectionLabel+section.textScript__c;
            }            
        }
        String formattedtext= formatText(textToFormat, recordId, record);
        return formattedtext;   
    }

    /* private override String formatText(String textScript, String recordId){

    } */

    private List<String> getAllFieldsToQuery(ScriptConfig__c process){
        String textToFormat='';
        system.debug(process.ChildSections__r.size());
        
        List<String> conditions = new List<String>();
        for(ScriptConfig__c section : process.ChildSections__r){
            if(String.isNotBlank(section.checkVisibility__c)){
                conditions.add(section.checkVisibility__c);
            }
            String sectionLabel = '<<{ globalTag.section__d.'+section.SectionLabel__c.replace(' ', '_')+ ' }>>';
            textToFormat +=sectionLabel+section.textScript__c;
        }

        List<String> allFieldsToQuery = getDataBinded(textToFormat);
        allFieldsToQuery.addAll(getListConditionFields(conditions));
        return allFieldsToQuery;
    }


    private Set<String> getListConditionFields(List<String> listConditions){
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
                actualFieldValue=getFieldValue(fieldName, record);
                visibility=assertDynamicValues(actualFieldValue, valueToCheck, checkCompare);
            }

        }catch(Exception ex ){
            System.debug('Exception: Script Section Check Condition - ' + ex.getTypeName() + ': ' + ex.getMessage() + ' -- ' + ex.getCause());
			return false;
        }
        return visibility;
    }



    private static Boolean assertDynamicValues(String actualFieldValue, String valueToCheck, Boolean checkEquals){
        //checkEquals true means that you must check if the two strings matches, if it false you check if the strings differ
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
