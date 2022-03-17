@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_LC_AppointmentExtraSist {
    @AuraEnabled(cacheable = true)
    public static String getLink(String recordId){
        List <wrts_prcgvr__Activity__c> listAct=new list <wrts_prcgvr__Activity__c>();
        listAct=HDT_QR_GenericQuery.getGenericRecords('Distributor__r.Name', 'wrts_prcgvr__Activity__c', 'Id = \''+String.escapeSingleQuotes(recordId)+'\'');
        system.debug(LoggingLevel.DEBUG,'@@@lista  ' + listAct[0].Distributor__r.Name);
        Map<String,String> response = new Map<String,String>();
        if(listAct!=null && listAct.size()!=0 && string.isNotBlank(listAct[0].Distributor__r.Name)){
            response=HDT_UTL_AppointmentSetting.getQuickLink(listAct[0].Distributor__r.Name);
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
}