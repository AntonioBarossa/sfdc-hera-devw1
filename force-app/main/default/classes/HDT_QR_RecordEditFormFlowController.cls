public inherited sharing class HDT_QR_RecordEditFormFlowController {

    public static List<HDT_UserInputFlow__mdt> queryInput(String processType){

        List<HDT_UserInputFlow__mdt> userInputFlowList = new List<HDT_UserInputFlow__mdt>();

        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('HDT_UserInputFlow__mdt','FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c','read');

        securityClass.checkSecurityAccess();

        try {
            
            userInputFlowList = [
            SELECT FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType
            LIMIT 1
        ];
        
        }catch(Exception e){

            throw new AuraHandledException('Errore');

        }
        return userInputFlowList;
        
    }
    
    
    public static List<ContentDocumentLink> queryCdLink(Id arecordId){

        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('ContentDocumentLink','ContentDocumentId','read');

        securityClass.checkSecurityAccess();
        
        List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        
        return cdLs;
        
    }
    
    public static List<ContentDocument> queryCd(List <Id> cdIdList){

        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('ContentDocument','Id, Title, FileType,CreatedDate','read');

        securityClass.checkSecurityAccess();
        
        List<ContentDocument> entries = [SELECT Id, Title, FileType,CreatedDate FROM ContentDocument WHERE ContentDocument.Id IN :cdIdList];
        
        return entries;
        
    }
    
    
}