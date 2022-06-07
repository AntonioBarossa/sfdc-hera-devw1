public with sharing class HDT_LC_ActivityTrace {
    public HDT_LC_ActivityTrace() {

    }
    @AuraEnabled(cacheable = true)
    public static string getActivity(Id recordId){
        String result;
        try {
            HDT_QR_GenericQuery qrClass = new HDT_QR_GenericQuery();
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            List<SObject> objRecord =  HDT_QR_GenericQuery.getGenericRecords('Activity__c', sObjName, 'Id =\''+recordId+'\'');
            if(!objRecord.isEmpty() && objRecord[0].get('Activity__c') != null){
                result = String.valueOf(objRecord[0].get('Activity__c'));
                /*List<wrts_prcgvr__Activity__c> actList = (List<wrts_prcgvr__Activity__c>)HDT_QR_GenericQuery.getGenericRecords('Name, Type__c, ActivityStartTime__c, ActivityEndTime__c, ActivityDurationFormula__c,', 'wrts_prcgvr__Activity__c', 'Id =\''+objRecord[0].get('Activity__c')+'\'');
                if(actList != null && !actList.isEmpty()){
                    resultMap.put('show', 'true');
                    resultMap.put('name', String.valueOf(actList[0].get('Name')));
                    resultMap.put('type', String.valueOf(actList[0].get('Type__c')));
                    resultMap.put('start', String.valueOf(actList[0].get('ActivityStartTime__c')));
                    resultMap.put('end', String.valueOf(actList[0].get('ActivityEndTime__c')));
                    resultMap.put('duration', String.valueOf(actList[0].get('ActivityDurationFormula__c')));
                }*/
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
}
