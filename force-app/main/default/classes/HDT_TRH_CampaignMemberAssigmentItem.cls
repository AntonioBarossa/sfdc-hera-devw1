/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 19/03/2021
* @description HDT_TRH_CampaignMemberAssigmentItem
* @history Fatjola Memishaj – 19/03/2021 – Created class
*/
public class HDT_TRH_CampaignMemberAssigmentItem extends HDT_TRH_TriggerHandler {

    public override void beforeInsert(){  
        HDT_UTL_CampaignMemberAssigmentItem.createCampaignMemberAssigmentItem(trigger.new);  
    }

    public override void beforeUpdate(){  
        HDT_UTL_CampaignMemberAssigmentItem.updateCampaignMemberAssigmentItem(trigger.new);  
    }
}
