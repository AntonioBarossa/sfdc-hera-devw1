/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 18/03/2021
* @description Class HDT_TRH_Quote
* @history Keltin Mesonjesi 18/03/2021 – Created class
*/
public inherited sharing class HDT_TRH_Quote extends HDT_TRH_TriggerHandler {
    
    public override void beforeInsert(){
        system.debug('Quote beforeInsert START');
        HDT_UTL_QuoteProcess.amendProcessManagementBefore(Trigger.New);
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
        HDT_UTL_Utils.setUsersField(trigger.new);
        system.debug('Quote beforeInsert END');
    }

    public override void afterInsert(){
        system.debug('Quote afterInsert START');
        HDT_UTL_QuoteProcess.amendProcessManagementAfter(Trigger.New);
        system.debug('Quote afterInsert END');
    }
}
