public inherited sharing class HDT_TRH_CampaignMember extends HDT_TRH_TriggerHandler{
    public override void beforeInsert(){  
        HDT_UTL_CampaignMember.createCampaignMember(trigger.new);
    }

    public override void afterInsert(){
        HDT_UTL_CampaignMember.createCommercialCode(trigger.new);
    }
    
}