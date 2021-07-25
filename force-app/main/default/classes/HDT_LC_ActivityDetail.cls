/**
 * @author Marco Arci (marco.arci@webresults.it)
 * @date 23/07/2021
 * @description HDT_LC_ActivityDetail - Classe(query) chiamata da hdtActivityDetail
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

 public with sharing class HDT_LC_ActivityDetail {
/*
    @AuraEnabled
    public static wrts_prcgvr__Activity__c getActivityById(Id idActivity){
        return [SELECT Id, wrts_prcgvr__ActivityTemplate__c FROM wrts_prcgvr__Activity__c WHERE Id=:idActivity];
    }

    @AuraEnabled
    public static wrts_prcgvr__ActivityTemplate__c getActivityTemplateById(Id idActivityTemplate){
        return [SELECT Id, wrts_prcgvr__FieldsTemplate__c FROM wrts_prcgvr__ActivityTemplate__c WHERE Id=:idActivityTemplate];
    }

    @AuraEnabled
    public static wrts_prcgvr__FieldsTemplate__c getFieldsTemplateById(Id idFieldsTemplate){
        return [SELECT Id FROM wrts_prcgvr__FieldsTemplate__c WHERE Id=:idFieldsTemplate];
    }

    @AuraEnabled
    public static wrts_prcgvr__DynamicSection__c getDynamicSectionByFieldsTemplateId(Id idFieldsTemplate){
        return [SELECT Id, wrts_prcgvr__Layout__c FROM wrts_prcgvr__DynamicSection__c WHERE wrts_prcgvr__Layout__c=:idFieldsTemplate];
    }

    @AuraEnabled
    public static wrts_prcgvr__DynamicField__c getDynamicFieldByDynamicSectionId(Id idDynamicSection){
        return [SELECT Id, wrts_prcgvr__Section__c FROM wrts_prcgvr__DynamicField__c WHERE wrts_prcgvr__Section__c=:idDynamicSection];
    }
*/
    @AuraEnabled
    public static map<string,list<Object>> getDetail(Id idActivity){
        map<string,list<Object>> details= new Map<String,list<Object>>();
        list<wrts_prcgvr__Activity__c> activity=[SELECT Id, wrts_prcgvr__ActivityTemplate__c FROM wrts_prcgvr__Activity__c WHERE Id=:idActivity];
        details.put('activity',activity);
        list<wrts_prcgvr__ActivityTemplate__c> activityTemplate=[SELECT Id, wrts_prcgvr__FieldsTemplate__c FROM wrts_prcgvr__ActivityTemplate__c WHERE Id=:activity[0].wrts_prcgvr__ActivityTemplate__c];
        details.put('activityTemplate',activityTemplate);
        list<wrts_prcgvr__FieldsTemplate__c> fieldsTemplate=[SELECT Id FROM wrts_prcgvr__FieldsTemplate__c WHERE Id=:activityTemplate[0].wrts_prcgvr__FieldsTemplate__c];
        details.put('fieldsTemplate',fieldsTemplate);
        list<wrts_prcgvr__DynamicSection__c> dynamicSection=[SELECT Id, wrts_prcgvr__Layout__c FROM wrts_prcgvr__DynamicSection__c WHERE wrts_prcgvr__Layout__c IN: fieldsTemplate];
        details.put('dynamicSection',dynamicSection);
        list<wrts_prcgvr__DynamicField__c> dynamicField=[SELECT Id, wrts_prcgvr__Section__c FROM wrts_prcgvr__DynamicField__c WHERE wrts_prcgvr__Section__c IN: dynamicSection];
        details.put('dynamicField',dynamicField);
        system.debug(details);
        return details;
    }

}