@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_LC_AppointmentExtraSist {
    @AuraEnabled(cacheable = true)
    public static String getLink(String recordId){
        List <wrts_prcgvr__Activity__c> listAct=new list <wrts_prcgvr__Activity__c>();
        listAct=HDT_QR_GenericQuery.getGenericRecords('Distributor__r.Name, Distributor__r.Code__c, Distributor__r.Commodity__c', 'wrts_prcgvr__Activity__c', 'Id = \''+String.escapeSingleQuotes(recordId)+'\'');
        String distributor = format(listAct[0].Distributor__r.Name);
        system.debug(LoggingLevel.DEBUG,'@@@lista  ' + distributor);
        Map<String,String> response = new Map<String,String>();
        if(listAct!=null && listAct.size()!=0 && string.isNotBlank(distributor)){
            response=HDT_UTL_AppointmentSetting.getQuickLink(distributor, listAct[0].Distributor__r.Code__c, listAct[0].Distributor__r.Commodity__c);
            if(response.containsKey('link')){
                System.debug(LoggingLevel.DEBUG,'@@@Link '+response.get('link'));
            }
            else if(response.containsKey('errorMessage')) {
                System.debug(LoggingLevel.DEBUG,'@@@Error '+response.get('errorMessage'));
            }
            return JSON.serialize(response);
        }
        else {
            return null;
        }
    }

    @AuraEnabled(cacheable = true)
    public static String getActivity(String activityId,List<String> fields){
        if (String.isNotBlank(activityId)){
            Map<String,Object> response = new Map<String,Object>();
            String fieldsToString = String.join(fields,',');
            if (!fieldsToString.containsIgnoreCase('isUserActivity__c')){
                fieldsToString += ',isUserActivity__c';
            }
            try{
                wrts_prcgvr__Activity__c activity = HDT_UTL_AppointmentAgenda.getActivity(activityId, fieldsToString);
                response.put('activity',activity);
                response.put('isNotOwner',!activity.isUserActivity__c); 
            }catch (Exception e){
                throw new AuraException(e.getMessage());
            }
            return JSON.serialize(response);
        }
        return null;
    }
    @AuraEnabled
    public static Boolean getActivityOwner(String activityId){
        try{
            String fieldsToString = 'Id,isUserActivity__c';
            wrts_prcgvr__Activity__c activity = HDT_UTL_AppointmentAgenda.getActivity(activityId, fieldsToString);
            
            return !activity.isUserActivity__c;
        }
        catch(Exception e){
            throw new AuraException(e.getMessage());
        }
    }

    private static String format(String value){
        return value.replaceFirst('[ ]?[-][ ]?[1]([0]|[3])([Dd]|[Rr])[0-9]{4,9}','');
    }
}