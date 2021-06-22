public inherited sharing class HDT_LC_AccountSelezionaRecordtype {
    @AuraEnabled
    public static List<Map<String,String>> getRecordTypesForAccount(){
        List<Schema.RecordTypeInfo> recordTypes = Account.SObjectType.getDescribe().getRecordTypeInfos();
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
