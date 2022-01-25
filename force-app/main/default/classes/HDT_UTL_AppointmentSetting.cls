public with sharing class HDT_UTL_AppointmentSetting {
    
    public static HDT_AppointmentSetting__mdt getAtoaFlag(String process, String distributorName, String commodity, String codVend){
        Map<String,HDT_AppointmentSetting__mdt> allRecordMap = new Map<String,HDT_AppointmentSetting__mdt>();
        if (String.isNotBlank(process)){
            for (HDT_AppointmentSetting__mdt record : [SELECT Flag__c,Value2__c, Value3__c,Value4__c  FROM HDT_AppointmentSetting__mdt WHERE Value1__c = :process AND (Value2__c = :distributorName OR Value2__c = '') AND (Value3__c = :commodity OR Value3__c = '')AND (Value4__c = :codVend OR Value4__c = '') AND IsActive__c = true AND Type__c = 'Appuntamento AtoA' WITH SECURITY_ENFORCED]){
                if (String.isNotEmpty(record.Value2__c) && String.isNotEmpty(record.Value3__c) && String.isNotEmpty(record.Value4__c) ){
                    allRecordMap.put(record.Value2__c.toUpperCase()+'-'+record.Value3__c.toUpperCase()+'-'+record.Value4__c.toUpperCase(),record);
                    break;
                }else if (String.isNotEmpty(record.Value2__c) && String.isNotEmpty(record.Value4__c)){
                    allRecordMap.put(record.Value2__c.toUpperCase()+'-'+record.Value4__c.toUpperCase(),record);
                }else if (String.isNotEmpty(record.Value3__c) && String.isNotEmpty(record.Value4__c)){
                    allRecordMap.put(record.Value3__c.toUpperCase()+'-'+record.Value4__c.toUpperCase(),record);
                }else if (String.isNotEmpty(record.Value2__c) && String.isNotEmpty(record.Value3__c)){
                    allRecordMap.put(record.Value2__c.toUpperCase()+'-'+record.Value3__c.toUpperCase(),record);
                }else if (String.isNotEmpty(record.Value4__c)){
                    allRecordMap.put(record.Value4__c.toUpperCase(),record);
                }else if (String.isNotEmpty(record.Value2__c)){
                    allRecordMap.put(record.Value2__c.toUpperCase(),record);
                }else if (String.isNotEmpty(record.Value3__c)){
                    allRecordMap.put(record.Value3__c.toUpperCase(),record);
                }else{
                    allRecordMap.put(toUpperCase(process),record);
                }
            }
        }
        
        HDT_AppointmentSetting__mdt response;
        if (allRecordMap.containsKey(toUpperCase(distributorName)+'-'+toUpperCase(commodity)+'-'+toUpperCase(codVend))){
            response = allRecordMap.get(toUpperCase(distributorName)+'-'+toUpperCase(commodity)+'-'+toUpperCase(codVend));
        }else if (allRecordMap.containsKey(toUpperCase(distributorName)+'-'+toUpperCase(codVend))){
            response = allRecordMap.get(toUpperCase(distributorName)+'-'+toUpperCase(codVend));
        }else if (allRecordMap.containsKey(toUpperCase(commodity)+'-'+toUpperCase(codVend))){
            response = allRecordMap.get(toUpperCase(commodity)+'-'+toUpperCase(codVend));
        }else if (allRecordMap.containsKey(toUpperCase(distributorName)+'-'+toUpperCase(commodity))){
            response = allRecordMap.get(toUpperCase(distributorName)+'-'+toUpperCase(commodity));
        }else if (allRecordMap.containsKey(toUpperCase(codVend))){
            response = allRecordMap.get(toUpperCase(codVend));
        }else if (allRecordMap.containsKey(toUpperCase(distributorName))){
            response = allRecordMap.get(toUpperCase(distributorName));
        }else if (allRecordMap.containsKey(toUpperCase(commodity))){
            response = allRecordMap.get(toUpperCase(commodity));
        }else if (allRecordMap.containsKey(toUpperCase(process))){
            response = allRecordMap.get(toUpperCase(process));
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

    public static Map<String,String> getQuickLink(String distributorName){
        Map<String,String> response = new Map<String,String>();
        try {
            HDT_AppointmentSetting__mdt record = [SELECT Value2__c FROM HDT_AppointmentSetting__mdt WHERE IsActive__c = true AND Type__c = 'Quick Link' AND Value1__c =:distributorName WITH SECURITY_ENFORCED];
            if (String.isEmpty(record.Value2__c)){
                response.put('errorMessage','Nessun Link valido per il presente distributore.');
            }else{
                response.put('link',record.Value2__c);
            }
        }catch (Exception e){
            response.put('errorMessage','Nessun Link valido per il presente distributore.');
        }
        return response;
    }

    public static String getCommunityLink(String organitationId){
        if (String.isNotBlank(organitationId)){
            for (HDT_AppointmentSetting__mdt record : [SELECT Value2__c  FROM HDT_AppointmentSetting__mdt WHERE (Value1__c = :organitationId OR Value1__c = :organitationId.substring(0,organitationId.length()-3)) AND IsActive__c = true AND Type__c = 'Link Community' WITH SECURITY_ENFORCED]){
                if (String.isNotEmpty(record.Value2__c)){
                    return record.Value2__c;
                }
            }
        }
        return 'link inesistente';
    }

    private static String toUpperCase(String value){
        if (value == null){
            value = '*';
        }
        return value.toUpperCase();
    }
}
