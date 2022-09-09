/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 31/05/2021
* @description HDT_TRH_CampaignMember
* @history Lorenzo – 31/05/2021 – created class
*/
public inherited sharing class HDT_TRH_CampaignMember extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){  
        HDT_UTL_CampaignMember.handleStatusChange(trigger.new, (Map<Id,CampaignMember>) trigger.oldMap);
        HDT_UTL_CampaignMember.setValidityStartDate(trigger.new);
        HDT_UTL_CampaignMember.createCampaignMember(trigger.new);
        HDT_UTL_CampaignMember.setAgency(trigger.new);
        HDT_UTL_CampaignMember.assignCmAgency(trigger.new);
    }
    
    public override void beforeUpdate(){
        HDT_UTL_CampaignMember.handleStatusChange(trigger.new, (Map<Id,CampaignMember>) trigger.oldMap);
    }
    
    public override void afterUpdate(){
        HDT_UTL_CampaignMember.checkTipoEsito((List<CampaignMember>) trigger.new, (Map<Id,CampaignMember>) trigger.oldMap);
    }
    public override void afterInsert(){
        if(Trigger.new != null && Trigger.new.size() == 1 && !System.isBatch())
        {
        HDT_UTL_CampaignMember.assignCallDateTimeHandle((List<CampaignMember>) trigger.new);
        }
    }
}