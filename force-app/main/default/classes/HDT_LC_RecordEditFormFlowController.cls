public without sharing class HDT_LC_RecordEditFormFlowController {
    
    @AuraEnabled(cacheable=true)
    public static String getFields(String processType) {
        String userInputFlow;
        List<HDT_UserInputFlow__mdt> userInputFlowList = [
            SELECT FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType
            LIMIT 1
        ];

        if(userInputFlowList.size() > 0 ){
            userInputFlow = JSON.serialize(userInputFlowList);
            
        }
        return userInputFlow;
    }

    @AuraEnabled(cacheable=true)
    public static String validateRecord(String validateClass, String fields, String recordId) {
        String result;
        System.debug('in class ' + fields);
        if(validateClass != null && String.isNotBlank(validateClass)){
            HDT_UTL_CaseValidationInterface support = HDT_UTL_CaseValidationFactory.getInstance(validateClass);
            result = support.validate(fields,recordId);
        }else{
            result = JSON.serialize(new HDT_UTL_CaseValidationWrapper('OK','Success'));
        }
        return result;
    }

    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId)
    {   
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        if (CDLs.size() < 1) return new List<ContentDocument>(); 

        // Make a List of ContentDocument IDs
        List <Id> CDIdList = new List <Id> ();
        for (ContentDocumentLink nextCDL : CDLs) {
            CDIdList.add(nextCDL.ContentDocumentId); }        

        List<ContentDocument> entries = [SELECT Id, Title, FileType,CreatedDate FROM ContentDocument WHERE ContentDocument.Id IN :CDIdList];
        return entries;
    }
}