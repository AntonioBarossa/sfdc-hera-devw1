public with sharing class HDT_BA_CampaignBolletta implements Database.Batchable<CampaignMember>, Database.AllowsCallouts {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public List<CampaignMember> campaignMembers;
    public Campaign campaign;
    public HDT_BA_CampaignBolletta(String campaignId) {
        Campaign cmp = [SELECT Name, Description, StaticTextMessageBill__c, Channel__c FROM Campaign WHERE Id = :campaignId AND Channel__c INCLUDES ('Bolletta') WITH SECURITY_ENFORCED];
        this.campaign = cmp;
        this.campaignMembers = [SELECT ContractReference__c,PromoCommercialCode__r.fullcode__c FROM CampaignMember WHERE CampaignId = :campaignId AND ContractReference__c != null AND isWsBollettaInvoked__c = false WITH SECURITY_ENFORCED];
        System.debug('campaginName - '+ cmp.Name);
    }

    public Iterable<CampaignMember> start(Database.BatchableContext bc) {
        return this.campaignMembers;
    }

    public void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest> wsReqList = new List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest>();

        for (CampaignMember cm : scope) {
                HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest wsReq = new HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest();
                wsReq.campaignId = this.campaign.Id;
                wsReq.campaignName = this.campaign.Name;
                wsReq.campaignDescription = this.campaign.Description;
                wsReq.comunicationText = this.campaign.StaticTextMessageBill__c == null ? cm.PromoCommercialCode__r.fullcode__c : this.campaign.StaticTextMessageBill__c + ' ' + cm.PromoCommercialCode__r.fullcode__c;
                wsReq.contractCode = cm.ContractReference__c != null ? cm.ContractReference__c : '';
                
                System.debug(wsReq);
                wsReqList.add(wsReq);
        }
        
        //WS call
        if (wsReqList.size() > 0) {
            HDT_WS_Response res = HDT_WS_CampaignBolletta.channelBolletta(wsReqList);
            System.debug(res);
            if (res.status != 'failed') {
                for (CampaignMember cm : scope) {
                    CampaignMember newCm = new CampaignMember();
                    newCm.Id = cm.Id;
                    newCm.isWsBollettaInvoked__c = true;
                    membersToUpdate.add(newCm);
                }
                if (membersToUpdate.size() > 0) {
                    update membersToUpdate;
                }
            }
        }        
    }

    public void finish(Database.BatchableContext bc){
        System.debug('-------- finish batch');
    }
}