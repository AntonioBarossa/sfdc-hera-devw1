public inherited sharing class HDT_TRH_Quote extends HDT_TRH_TriggerHandler {
    
    public override void beforeInsert(){
        system.debug('Quote beforeInsert START');
        HDT_UTL_QuoteProcess.amendProcessManagementBefore(Trigger.New);
        HDT_UTL_CompanyOwner.feedCompanOwner(trigger.new);
        system.debug('Quote beforeInsert END');
    }

    public override void afterInsert(){
        system.debug('Quote afterInsert START');
        HDT_UTL_QuoteProcess.amendProcessManagementAfter(Trigger.New);
        system.debug('Quote afterInsert END');
    }
 	public override void beforeDelete(){}
 	public override void afterDelete(){}
    public override void beforeUpdate(){}
    public override void afterUpdate(){}
}
