public inherited sharing class HDT_QR_RecordEditFormFlowController {

    public static List<HDT_UserInputFlow__mdt> queryInput(String processType){
        
         List<HDT_UserInputFlow__mdt> userInputFlowList = [
            SELECT FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType
            LIMIT 1
        ];
        
        return userInputFlowList;
        
    }
    
    
    public static List<ContentDocumentLink> queryCdLink(Id arecordId){
        
        List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        
        return cdLs;
        
    }
    
    public static List<ContentDocument> queryCd(List <Id> cdIdList){
        
        List<ContentDocument> entries = [SELECT Id, Title, FileType,CreatedDate FROM ContentDocument WHERE ContentDocument.Id IN :cdIdList];
        
        return entries;
        
    }
    
    
}