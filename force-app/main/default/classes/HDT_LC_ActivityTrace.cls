public with sharing class HDT_LC_ActivityTrace {
    public HDT_LC_ActivityTrace() {

    }
    @AuraEnabled(cacheable = true)
    public static string getActivity(Id recordId){
        String result;
        Map<String,String> resultMap = new Map<String,String>();
        resultMap.put('Tipo', 'Non definito');
        String qField;
        try {
            HDT_QR_GenericQuery qrClass = new HDT_QR_GenericQuery();
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(sObjName.equalsIgnoreCase('Case') || sObjName.equalsIgnoreCase('Order')){
                qField = 'Activity__c,Interaction__c';
            }else {
                qField = 'Activity__c';
            }
            List<SObject> objRecord =  HDT_QR_GenericQuery.getGenericRecords(qField, sObjName, 'Id =\''+recordId+'\'');
            if(!objRecord.isEmpty() && objRecord[0].get('Activity__c') != null){
                result = String.valueOf(objRecord[0].get('Activity__c'));
                resultMap.put('Tipo', 'Activity');
                resultMap.put('Id', result);
            }else if (!objRecord.isEmpty() && objRecord[0].get('Interaction__c') != null) {
                result = String.valueOf(objRecord[0].get('Interaction__c'));
                resultMap.put('Tipo', 'Interaction');
                resultMap.put('Id', result);
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(resultMap);
    }
}
