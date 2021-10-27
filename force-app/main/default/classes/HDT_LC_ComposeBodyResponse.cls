@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_LC_ComposeBodyResponse{
    
    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled(Cacheable = false)
    public static void buildResponse(List<String> templates, List<String> currentTemplates, String recordId, Boolean deleteAll){

        Case c = [SELECT ComplaintBodyResponse__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

        if(c.ComplaintBodyResponse__c == null || deleteAll == true){
            c.ComplaintBodyResponse__c = '';
            if(deleteAll == true){
                HDT_UTL_DatabaseService.updateSObject(c);
                return;
            }
        }
        
        for(String template : templates){
            System.debug(LoggingLevel.DEBUG, 'buildResponse -  has template:' + !currentTemplates.contains(template));
            if(!currentTemplates.contains(template)){
                c.ComplaintBodyResponse__c += template + '\n';
            }
        }

        HDT_UTL_DatabaseService.updateSObject(c);
        return;
    }


    @AuraEnabled
    public static string updateResponse(String fieldValue, String recordId){

        Case c = [SELECT ComplaintBodyResponse__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
        c.ComplaintBodyResponse__c = fieldValue;
        HDT_UTL_DatabaseService.updateSObject(c);
        return null;
    }

    @AuraEnabled
    public static string stripHtml(String inputHtml){
        return inputHtml.stripHtmlTags();
    }
}
