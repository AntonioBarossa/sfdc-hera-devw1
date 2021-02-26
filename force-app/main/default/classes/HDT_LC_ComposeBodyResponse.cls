public inherited sharing class HDT_LC_ComposeBodyResponse{

    @AuraEnabled(Cacheable = false)
    public static void buildResponse(List<String> templates, String recordId, Boolean deleteAll){

        Case c = [SELECT ComplaintBodyResponse__c FROM Case WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

        if(c.ComplaintBodyResponse__c == null || deleteAll == true){

            c.ComplaintBodyResponse__c = '';

            if(deleteAll == true){

                HDT_UTL_DatabaseService.updateSObject(c);

                return;

            }

        }

       
        for(String template : templates){

            c.ComplaintBodyResponse__c += template + '\n';

        }

        HDT_UTL_DatabaseService.updateSObject(c);

        return;

    }

}



    