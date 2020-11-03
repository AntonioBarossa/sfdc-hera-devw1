public with sharing class HDT_UTL_SObjectUtils {

    public static String getSobjectTypeName(final List<sObject> sObjectList) {
        return sObjectList.get(0).getSObjectType().getDescribe().getName();
    }

    public static String getSobjectTypeName(final List<Id> idList) {
        return idList.get(0).getSObjectType().getDescribe().getName();
    }

    public static List<String> listNotNullByField(SObject[] sObjectList, Schema.SObjectField field) {
        List<String> values = new List<String>();
        for(SObject sObj : sObjectList) {
            String value = (String) sObj.get(field);
            if(String.isNotBlank(value)) {
                values.add(value);
            }
        }
        return values;
    }

    public static Set<String> setNotNullByField(SObject[] sObjectList, Schema.SObjectField field) {
        Set<String> values = new Set<String>();
        for(SObject sObj : sObjectList) {
            String value = (String) sObj.get(field);
            if(String.isNotBlank(value)) {
                values.add(value);
            }
        }
        return values;
    }

    public static Set<Id> setIdByField(SObject[] sObjectList, Schema.SObjectField field) {
        Set<Id> values = new Set<Id>();
        for(SObject sObj : sObjectList) {
            Id value = (Id) sObj.get(field);
            if(value!=null) {
                values.add(value);
            }
        }
        return values;
    }

    public static Map<String, String> mapTwoFields(SObject[] sObjectList, Schema.SObjectField keyfield, Schema.SObjectField valuefield) {
        Map<String, String> fieldNamesMap = new Map<String, String>();
        for(SObject sObj : sObjectList) {
            String value = (String) sObj.get(keyfield);
            if(!fieldNamesMap.containsKey(value)) {
                fieldNamesMap.put(value, (String)sObj.get(valuefield));
            }
        }
        return fieldNamesMap;
    }

    public static Map<String, SObject> mapByFieldAndSobject(SObject[] sObjectList, Schema.SObjectField field) {
        Map<String, SObject> fieldSobjectMap = new Map<String, SObject>();
        for(SObject sObj : sObjectList) {
            String value = (String) sObj.get(field);
            if(!fieldSobjectMap.containsKey(value)) {
                fieldSobjectMap.put(value, sObj);
            }
        }
        return fieldSobjectMap;
    }

    public static Map<String, SObject[]> mapByFieldAndList(SObject[] sObjectList, Schema.SObjectField field) {
        Map<String, SObject[]> fieldSobjectMap = new Map<String, SObject[]>();
        for(SObject sObj : sObjectList) {
            String key = (String) sObj.get(field);
            SObject[] values = null;
            if(fieldSobjectMap.containsKey(key)) {
                values = fieldSobjectMap.get(key);
            } else {
                values = new List<SObject>();
                fieldSobjectMap.put(key, values);
            }
            values.add(sObj);
        }
        return fieldSobjectMap;
    }

    public static Map<String, Set<String>> mapFieldAndSet(SObject[] sObjectList, Schema.SObjectField keyfield, Schema.SObjectField valuefield) {
        Map<String, Set<String>> fieldNamesMap = new Map<String, Set<String>>();
        for(SObject sObj : sObjectList) {
            String key = (String) sObj.get(keyfield);
            Set<String> values = null;
            if(fieldNamesMap.containsKey(key)) {
                values = fieldNamesMap.get(key);
            } else {
                values = new Set<String>();
                fieldNamesMap.put(key, values);
            }
            values.add((String)sObj.get(valuefield));
        }
        return fieldNamesMap;
    }
}