public with sharing class HDT_UTL_AppointmentSetting {
    
    public static HDT_AppointmentSetting__mdt getAtoaFlag(String process, String distributorName, String commodity){
        Map<String,HDT_AppointmentSetting__mdt> allRecordMap = new Map<String,HDT_AppointmentSetting__mdt>();
        for (HDT_AppointmentSetting__mdt record : [SELECT Flag__c,Value2__c, Value3__c  FROM HDT_AppointmentSetting__mdt WHERE Value1__c = :process AND (Value2__c = :distributorName OR Value2__c = '') AND (Value3__c = :commodity OR Value3__c = '') AND IsActive__c = true AND Type__c = 'Appuntamento AtoA' WITH SECURITY_ENFORCED]){
            if (String.isNotEmpty(record.Value2__c) && String.isNotEmpty(record.Value3__c)){
                allRecordMap.put(record.Value2__c+'-'+record.Value3__c,record);
                break;
            }else if (String.isNotEmpty(record.Value2__c)){
                allRecordMap.put(record.Value2__c,record);
            }else if (String.isNotEmpty(record.Value3__c)){
                allRecordMap.put(record.Value3__c,record);
            }else{
                allRecordMap.put(process,record);
            }
        }
        HDT_AppointmentSetting__mdt response;
        if (allRecordMap.containsKey(distributorName+'-'+commodity)){
            response = allRecordMap.get(distributorName+'-'+commodity);
        }else if (allRecordMap.containsKey(distributorName)){
            response = allRecordMap.get(distributorName);
        }else if (allRecordMap.containsKey(commodity)){
            response = allRecordMap.get(commodity);
        }else if (allRecordMap.containsKey(process)){
            response = allRecordMap.get(process);
        }
        return response;
    }

    public static Map<String,String> getResponseKeysMap(){
        Map<String,String> response = new Map<String,String>();
        for (HDT_AppointmentSetting__mdt record : [SELECT Value1__c, Value2__c FROM HDT_AppointmentSetting__mdt WHERE IsActive__c = true AND Type__c = 'Map Heroku' WITH SECURITY_ENFORCED]){
            response.put(record.Value1__c,record.Value2__c);
        }
        return response;
    }
}
