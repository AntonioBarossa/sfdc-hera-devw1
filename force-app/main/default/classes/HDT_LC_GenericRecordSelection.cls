public with sharing class HDT_LC_GenericRecordSelection {

    private static HDT_QR_GenericRecordSelection getterMethods = new HDT_QR_GenericRecordSelection();

    @AuraEnabled(cacheable = true)
    public static String getConfiguration(String search){
        String result;
        System.debug('Search ' + search);
        try{
            List<HDT_Generic_Record_Selection__mdt> configList = getterMethods.getConfigurationByName(search);
            if(configList != null && configList.size()>0){
                result = JSON.serialize(configList);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return result;
    }

    @AuraEnabled(cacheable = false)
    public static String getListRecords(String params){
        String recordListString;
        try{
            System.debug('params ' + params);
            HDT_WRP_GenericRecordSelection parameters = (HDT_WRP_GenericRecordSelection) JSON.deserialize(params, HDT_WRP_GenericRecordSelection.class);
            System.debug(parameters.filters);

            List<List<sObject>> recordList = null;
            if (parameters.queryType == 'SOSL') {
                recordList = getterMethods.executeQuery(parameters.fields, parameters.filters, parameters.limitStr, parameters.soslSearchTerm, parameters.objectName);
            } else if (parameters.queryType == 'SOQL') {
                recordList = new List<List<sObject>>();
                List<sObject> soqlRecordList = getterMethods.executeSoqlQuery(parameters.fields, parameters.filters, parameters.limitStr, parameters.objectName);
                recordList.add(soqlRecordList);
            }

            if(recordList != null){

                if(parameters.distinct != null && parameters.distinct.equalsIgnoreCase('true')){
                    recordList = getDistinctRecords(parameters.fields, recordList);
                }

                recordListString = JSON.serialize(recordList);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return recordListString;
    }

    private static List<List<sObject>> getDistinctRecords(String fields, List<List<sObject>> recordList) {

        List<List<SObject>> results = new List<List<SObject>>();

        try {
            List<String> fieldsList = fields.trim().split(',');
            System.debug(fieldsList);

            List<SObject> firstObjectList = recordList[0];

            String key = '';
            Map<String, Id> fieldsMap = new Map<String, Id>();
            Map<Id, SObject> objectsMap = new Map<Id, SObject>();

            for (SObject singleObject : firstObjectList) {
                for (String field : fieldsList) {
                    key += singleObject.get(field) + '-';
                }

                fieldsMap.put(String.valueOf(key), singleObject.Id);

                objectsMap.put(singleObject.Id, singleObject);
                key = '';
            }

            List<Id> distinctRecordIds = fieldsMap.values();

            List<sObject> outputRecords = new List<SObject>();
            for (Id recordId : distinctRecordIds) {
                outputRecords.add(objectsMap.get(recordId));

            }

            results.add(outputRecords);

        } catch(Exception e){
            System.debug(e.getMessage());
        }
        return results;

    }

    public class HDT_WRP_GenericRecordSelection{
        public String fields;
        public String filters;
        public String limitStr;
        public String soslSearchTerm;
        public String objectName;
        public String distinct;
        public String queryType;
    }
}