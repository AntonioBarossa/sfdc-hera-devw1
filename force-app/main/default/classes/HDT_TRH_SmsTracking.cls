public inherited sharing class HDT_TRH_SmsTracking extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanyOwner(trigger.new);
    }
    public override void afterUpdate(){
        HDT_UTL_Scarti.createScartoForMarketingCloud(trigger.new,trigger.oldMap);
    }
}