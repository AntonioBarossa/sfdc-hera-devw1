public inherited sharing class HDT_LC_ModificaContrattiBp {

    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();

    
    @AuraEnabled
    public static void updateBpDataOnCase (Map<String, Object> bpData, Id caseId){
        system.debug(JSON.serialize(bpData));
        try {
            //Set<String> caseFields = ((SObject)Type.forName('Schema','Product2').newInstance()).getSObjectType().getDescribe().fields.getMap().keySet();
            Set<String> caseFields = Schema.SObjectType.Case.fields.getMap().keySet();
            Map<String,String> unmappedField = new Map<String,String>{
                'PaymentMethod__c'=>'DocumentPaymentMethod__c',
                'SignatoryType__c'=>'AccountholderTypeBeneficiary__c',
                'undefined'=>'AccountholderTypeBeneficiary__c',
                'InvoiceEmailAddress__c'=>'InvoiceEmail__c'
            };
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.BillingProfile__c.fields.getMap();
            Case c = new Case(Id=caseId);
            Datetime nowDate = Datetime.now();
            c.Note__c = nowDate.format('dd/MM/yyyy h:mm a') + ' Campi Modificati:';
            for(String field : bpData.keySet())
            {
                if(bpData.get(field) != null && String.isNotBlank(String.valueOf(bpData.get(field))) && !field.equalsIgnoreCase('undefined'))
                {
                    //c.Note__c += '\n' + '\"' +fieldMap.get(field).getDescribe().getLabel() + '\"' + ': ' + '\"' + bpData.get(field) + '\"';
                    if(caseFields.contains(field.toLowerCase())){
                        c.put(field, bpData.get(field));
                    }else if(unmappedField.containsKey(field)){
                        c.put(unmappedField.get(field), bpData.get(field));
                    }
                }
            }
            HDT_UTL_DatabaseService.updateSObject(c);
        } catch (Exception e) {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.BillingProfile__c.fields.getMap();

    @AuraEnabled
    public static Map<String, Object> filterDataToBp (Map<String, Object> theCase){
        Map<String,Object> mapToReturn = new Map<String,Object>();
        String note = (String)theCase.get('Note__c');
        List<String> fieldsPopulated = note.split('\n');
        fieldsPopulated.remove(0);
        for(String s : fieldsPopulated)
        {
            List<String> fieldsMap = s.split(':');
            String fieldLabel = fieldsMap[0].substringBetween('\"');
            String fieldvalue = fieldsMap[1].substringBetween('\"');
            for(String fieldName : fieldMap.keySet())
            {
                if(fieldMap.get(fieldName).getDescribe().getLabel().equalsIgnoreCase(fieldLabel))
                {
                    mapToReturn.put(fieldMap.get(fieldName).getDescribe().getName(), fieldValue);
                }
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
