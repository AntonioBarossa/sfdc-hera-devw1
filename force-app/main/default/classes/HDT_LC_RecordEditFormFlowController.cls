public inherited sharing class HDT_LC_RecordEditFormFlowController {
    
    @AuraEnabled(cacheable=true)
    public static String getFields(String processType) {
        String userInputFlow;
        List<HDT_UserInputFlow__mdt> userInputFlowList = HDT_QR_RecordEditFormFlowController.queryInput(processType);
        /*List<HDT_UserInputFlow__mdt> userInputFlowList = [
            SELECT FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType
            LIMIT 1
        ];*/

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
        //List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        List<ContentDocumentLink> cdLs = HDT_QR_RecordEditFormFlowController.queryCdLink(arecordId);
        if (cdLs.size() < 1) return new List<ContentDocument>(); 

        // Make a List of ContentDocument IDs
        List <Id> cdIdList = new List <Id> ();
        for (ContentDocumentLink nextCdl : cdLs) {
            cdIdList.add(nextCdl.ContentDocumentId); }        

        //List<ContentDocument> entries = [SELECT Id, Title, FileType,CreatedDate FROM ContentDocument WHERE ContentDocument.Id IN :cdIdList];
        return HDT_QR_RecordEditFormFlowController.queryCd(cdIdList);
    }
}