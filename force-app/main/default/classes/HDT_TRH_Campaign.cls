public class HDT_TRH_Campaign extends HDT_TRH_TriggerHandler{
    
    // public override void afterInsert(){  

    //     HDT_UTL_CampaignMember.createCampaignMemberStatus(trigger.new);  
    // }

    public override void beforeInsert(){
        HDT_UTL_CompanyOwner.feedCompanOwner(trigger.new);
    }
    
    public override void beforeUpdate() {

        HDT_UTL_CampaignMember.createCampaignMemberStatus(trigger.new, trigger.old);  
    }
}
