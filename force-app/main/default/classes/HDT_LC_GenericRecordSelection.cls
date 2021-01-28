public with sharing class HDT_LC_GenericRecordSelection {
   
    private static HDT_QR_GenericRecordSelection getterMethods = new HDT_QR_GenericRecordSelection();

    @AuraEnabled(cacheable = false)
    public static String getListRecords(String params){
        String recordListString;
        try{
            System.debug('params ' + params);
            HDT_WRP_GenericRecordSelection parameters = (HDT_WRP_GenericRecordSelection) JSON.deserialize(params, HDT_WRP_GenericRecordSelection.class);
            System.debug(parameters.filters);
            List<List<sObject>> recordList = getterMethods.executeQuery(parameters.fields, parameters.filters, parameters.limitStr, parameters.soslSearchTerm, parameters.objectName); 
            if(recordList != null){
                recordListString = JSON.serialize(recordList);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return recordListString;
    }

    public class HDT_WRP_GenericRecordSelection{
        public String fields;
        public String filters;
        public String limitStr;
        public String soslSearchTerm;
        public String objectName;
    }
}
