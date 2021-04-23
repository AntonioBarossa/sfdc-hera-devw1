public with sharing class HDT_UTL_CampaignMember {

    public static void createCampaignMemberStatus(List<Campaign> newCampaigns, List<Campaign> oldCampaigns){

        Map<String,Campaign> mapCampaign = new Map<String,Campaign>();
        List<HDT_CampaignMemberStatus__mdt> campaignStatusMdt= HDT_QR_CampaignMemberStatusMetadata.getRecords();
        List<CampaignMemberStatus> campaignMemberStatuses= new List<CampaignMemberStatus>();

        List<Campaign> campaigns= new List<Campaign>();
        for(Campaign ce: oldCampaigns){
            mapCampaign.put(ce.id, ce);
        }
        for (Campaign cam: newCampaigns){
            Campaign oldCampaign = mapCampaign.get(cam.id);
            if(cam.Status != oldCampaign.Status ){
                if(oldCampaign.Status== 'Bozze' && cam.Status== 'Pianificata'){
                    campaigns.add(cam);
                }
            }
        }
        for(Campaign c: campaigns){
            for(HDT_CampaignMemberStatus__mdt cmdt: campaignStatusMdt){
                CampaignMemberStatus cam= new CampaignMemberStatus(CampaignId= c.Id, Label=cmdt.DeveloperName, HasResponded= cmdt.HasResponded__c, IsDefault= cmdt.Default__c);
                campaignMemberStatuses.add(cam);
            }
        }
        HDT_SRV_CampaignMemberStatus.createRecord(campaignMemberStatuses);


    }
}
