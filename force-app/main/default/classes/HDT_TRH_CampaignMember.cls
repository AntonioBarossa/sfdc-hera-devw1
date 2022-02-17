/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 31/05/2021
* @description HDT_TRH_CampaignMember
* @history Lorenzo – 31/05/2021 – created class
*/
public inherited sharing class HDT_TRH_CampaignMember extends HDT_TRH_TriggerHandler{

    public override void beforeInsert(){  
        HDT_UTL_CampaignMember.createCampaignMember(trigger.new);
        HDT_UTL_CampaignMember.parseStatusCode((Map<Id, CampaignMember>) trigger.newMap, (Map<Id, CampaignMember>) trigger.oldMap);
    }
    
    public override void afterInsert(){
        HDT_UTL_CampaignMember.createCommercialCode(trigger.new);
    }
    
    public override void beforeUpdate(){
        HDT_UTL_CampaignMember.parseStatusCode((Map<Id, CampaignMember>) trigger.newMap, (Map<Id, CampaignMember>) trigger.oldMap);
        HDT_UTL_CampaignMember.checkTipoEsito((List<CampaignMember>) Trigger.new,  (Map<Id, CampaignMember>) Trigger.oldMap);
    }
}