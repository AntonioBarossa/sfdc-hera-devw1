public with sharing class HDT_LC_ActivityTrace {
    public HDT_LC_ActivityTrace() {

    }
    @AuraEnabled(cacheable = true)
    public static string getActivity(Id recordId){
        String result;
        Map<String,String> resultMap = new Map<String,String>();
        resultMap.put('Tipo', 'Non definito');
        String qField;
        System.debug('PUNTO 1');
        try {
            System.debug('PUNTO 2');
            HDT_QR_GenericQuery qrClass = new HDT_QR_GenericQuery();
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            System.debug('PUNTO 3');
            if(sObjName.equalsIgnoreCase('Case') || sObjName.equalsIgnoreCase('Order')){
                System.debug('PUNTO 4');
                qField = 'Activity__c,Interaction__c';
            }else {
                System.debug('PUNTO 5');
                qField = 'Activity__c';
            }
            System.debug('PUNTO 6');
            List<SObject> objRecord =  HDT_QR_GenericQuery.getGenericRecords(qField, sObjName, 'Id =\''+recordId+'\'');
            System.debug('PUNTO 7');
            System.debug('objRecord --> '+objRecord);
            if(!objRecord.isEmpty() && objRecord[0].get('Activity__c') != null){
                System.debug('PUNTO 8');
                result = String.valueOf(objRecord[0].get('Activity__c'));
                resultMap.put('Tipo', 'Activity');
                resultMap.put('Id', result);
                System.debug('PUNTO 9');
                System.debug('resultMap --> '+resultMap);
            }else if (!objRecord.isEmpty() && objRecord[0].get('Interaction__c') != null) {
                System.debug('PUNTO 10');
                result = String.valueOf(objRecord[0].get('Interaction__c'));
                resultMap.put('Tipo', 'Interaction');
                resultMap.put('Id', result);
                System.debug('PUNTO 11');
                
            }
        } catch (Exception e) {
            resultMap.put('error', e.getMessage());
        }
        return JSON.serialize(resultMap);
    }
}
