public with sharing class HDT_UTL_ContentDocumentLink {
    public static void checkLead(List<ContentDocumentLink> newCDL){
        for(ContentDocumentLink cdl:newCDL){
            if(String.isNotBlank(cdl.LinkedEntityId) && cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Lead'){
                cdl.visibility = 'AllUsers';
            }
        }
    }
}