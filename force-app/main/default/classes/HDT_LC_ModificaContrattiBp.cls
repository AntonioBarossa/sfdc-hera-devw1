public inherited sharing class HDT_LC_ModificaContrattiBp {

    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();

    
    @AuraEnabled
    public static void updateBpDataOnCase (Map<String, Object> bpData, Id caseId){
        system.debug(bpData);
        try {
            //Set<String> caseFields = ((SObject)Type.forName('Schema','Product2').newInstance()).getSObjectType().getDescribe().fields.getMap().keySet();
            Set<String> caseFields = Schema.SObjectType.Case.fields.getMap().keySet();
            Case c = new Case(Id=caseId);
            List<String> fieldsNotMapped = new List<String>();
            for(String field : bpData.keyset()){
                if(caseFields.contains(field.toLowerCase())){
                    c.put(field, bpData.get(field));
                }else{
                    fieldsNotMapped.add(field);
                }
            }
            system.debug('Unmapped fields '+String.join(fieldsNotMapped, ' ,'));
            //if(fieldsNotMapped.isEmpty()){
                caseSrv.updateRecord(c);//mettere return, non update diretto, ritorna il case, facciamo uno spread in js 
                //con i dati degli indirizzi e poi lanciamo update
           // }else{
                //throw new HDT_LC_ModificaContrattiBpException('Unmapped fields '+String.join(fieldsNotMapped, ' ,'));
            //}
        } catch (Exception e) {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.BillingProfile__c.fields.getMap();

    @AuraEnabled
    public static Map<String, Object> filterDataToBp (Map<String, Object> theCase){
        Set<String> bpFields = fieldMap.keySet();
        Map<String, Object> mapToReturn = new Map<String, Object>();
        for(String field : theCase.keyset()){
            String fieldLow = field.toLowerCase();
            if(bpFields.contains(fieldLow) && isSafeUpdatableField(fieldLow)){
                mapToReturn.put(field, theCase.get(field));
            }
        }
        return mapToReturn;
    }

    private static boolean isSafeUpdatableField(String fieldName){
        SObjectField myField = fieldMap.get(fieldName);
        return myField.getDescribe().isUpdateable();
    }

    // exception class
    public class HDT_LC_ModificaContrattiBpException extends Exception {}
}
