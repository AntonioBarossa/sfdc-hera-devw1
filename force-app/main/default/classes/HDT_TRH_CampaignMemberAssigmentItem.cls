public class HDT_TRH_CampaignMemberAssigmentItem extends HDT_TRH_TriggerHandler {

    public override void beforeInsert(){  
        HDT_UTL_CampaignMemberAssigmentItem.createCampaignMemberAssigmentItem(trigger.new);  
    }

    public override void beforeUpdate(){  
        HDT_UTL_CampaignMemberAssigmentItem.updateCampaignMemberAssigmentItem(trigger.new);  
    }
}
