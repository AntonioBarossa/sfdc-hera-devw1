public with sharing class HDT_TRH_ContentDocumentLink extends HDT_TRH_TriggerHandler {
    public override void beforeInsert(){
        HDT_UTL_ContentDocumentLink.checkLead(trigger.new);
        
    }
}