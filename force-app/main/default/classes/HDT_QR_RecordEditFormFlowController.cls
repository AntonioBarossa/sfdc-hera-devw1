public inherited sharing class HDT_QR_RecordEditFormFlowController {

    public static List<HDT_UserInputFlow__mdt> queryInput(String processType){

        List<HDT_UserInputFlow__mdt> userInputFlowList = new List<HDT_UserInputFlow__mdt>();

        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('HDT_UserInputFlow__mdt','FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c,ReadOnlyRelatedFields__c','read');

        securityClass.checkSecurityAccess();

        try {
            
            userInputFlowList = [
            SELECT FieldsJSON__c, ValidateClass__c,ReadOnlyFields__c,ReadOnlyRelatedFields__c
            FROM HDT_UserInputFlow__mdt
            WHERE ProcessType__c =: processType 
            WITH SECURITY_ENFORCED           
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
        
        List<ContentDocumentLink> cdLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId WITH SECURITY_ENFORCED];
        
        return cdLs;
        
    }
    
    public static List<ContentDocument> queryCd(List <Id> cdIdList){

        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('ContentDocument','Id, Title, FileType,CreatedDate','read');

        securityClass.checkSecurityAccess();
        
        List<ContentDocument> entries = [SELECT Id, Title, FileType,CreatedDate,ContentSize FROM ContentDocument WHERE ContentDocument.Id IN :cdIdList WITH SECURITY_ENFORCED];
        
        return entries;
        
    }

    public static List<HDT_RecordFormFieldDependency__mdt> getDependencyConfigurations(String controllingField,String controlledField,String processType, String objectDevName){
        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess('HDT_RecordFormFieldDependency__mdt','ControlledField__c, ControllingField__c, DependecyJSON__c, ProcessType__c, ObjectDeveloperName__c','read');
        securityClass.checkSecurityAccess();
        return [
                SELECT ControlledField__c, ControllingField__c, DependecyJSON__c, ProcessType__c
                FROM HDT_RecordFormFieldDependency__mdt
                WHERE ControlledField__c=:controlledField AND ControllingField__c=:controllingField AND ProcessType__c=:processType AND ObjectDeveloperName__c=:objectDevName
                WITH SECURITY_ENFORCED
                LIMIT 1
        ];
    }

    public static List<SObject> getRecordFromIdQueryString(String fieldName, String objectName, String objectId){
        HDT_UTL_SecurityAccess securityClass = new HDT_UTL_SecurityAccess(objectName,'Id, '+fieldName,'read');
        securityClass.checkSecurityAccess();
        return Database.query('SELECT Id, '+fieldName+' FROM '+ objectName+' WHERE Id=:objectId WITH SECURITY_ENFORCED');
    }
    
    
}