/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 29/01/2021
 * @description HDT_LC_TargetObjectRecordTypeSelection.cls - Class that holds methods that are called from hdtTargetObjectRecordTypeSelection.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_TargetObjectRecordTypeSelection {

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get record types for ServicePoint__c
    * @return List<Map<String,String>>
    */
    @AuraEnabled
    public static List<Map<String,String>> getRecordTypesForServicePoint(){
        List<Schema.RecordTypeInfo> recordTypes = ServicePoint__c.SObjectType.getDescribe().getRecordTypeInfos();
        List<Map<String,String>> recordtypesList = new List<Map<String,String>>();
        

        for (Schema.RecordTypeInfo recordType : recordTypes) {
            Map<String,String> properties = new Map<String,String>();
            properties.put('DeveloperName', recordType.getDeveloperName());
            properties.put('label', recordType.getName());
            properties.put('value', recordType.getRecordTypeId());
            recordtypesList.add(properties);
        }

        return recordtypesList;
    }
}
