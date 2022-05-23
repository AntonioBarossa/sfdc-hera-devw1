public with sharing class HDT_UTL_TariCaseValidation implements HDT_UTL_CaseValidationInterface {

    public String validate(String fields, String recordId){

        if(getFieldValue(fields, 'Description') == '' || getFieldValue(fields, 'Description') == null){
            return JSON.serialize(new HDT_UTL_CaseValidationWrapper('Error', 'Popolare il campo descrizione'));
        }
        return JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK', 'Success'));
    }

    public String getFieldValue(String fields, String fieldToGet){
        Map<String, Object> fieldsMap = (Map<String, Object>) JSON.deserializeUntyped(fields);
        return String.valueOf(fieldsMap.get(fieldToGet));
    }
}