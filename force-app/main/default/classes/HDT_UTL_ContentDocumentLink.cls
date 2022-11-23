public with sharing class HDT_UTL_ContentDocumentLink {
    public static void checkLead(List<ContentDocumentLink> newCDL){
        for(ContentDocumentLink cdl:newCDL){
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Lead'){
                cdl.visibility = 'AllUsers';
            }
        }
    }
}