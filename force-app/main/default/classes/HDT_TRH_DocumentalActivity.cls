public inherited sharing class HDT_TRH_DocumentalActivity extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanOwner(trigger.new);
    }
}