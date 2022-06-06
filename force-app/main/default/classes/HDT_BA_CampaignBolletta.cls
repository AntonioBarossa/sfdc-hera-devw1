public with sharing class HDT_BA_CampaignBolletta implements Database.Batchable<CampaignMember>, Database.AllowsCallouts {
    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();

    public List<CampaignMember> campaignMembers;
    public List<Commercial_Code_Batch_Context__c> batchCSContext;//>> 30/05/22 costanzo.lomele@webresults.it #fix for campagne performance tests
    
    //START>> 30/05/22 costanzo.lomele@webresults.it #fix for campagne performance tests
    //public HDT_BA_CampaignBolletta(List<String> campaignIds) {
    public HDT_BA_CampaignBolletta() {
        List<Commercial_Code_Batch_Context__c> context = [SELECT Id, CampaignId__c, CampaignMemberId__c
                                                    		FROM Commercial_Code_Batch_Context__c 
                                                    		WHERE CommercialCodeDone__c = TRUE AND BollettaDone__c = FALSE];
        this.batchCSContext = context;
        Set<String> campaignIds = new Set<String>();
        for(Commercial_Code_Batch_Context__c curObj : context) campaignIds.add(curObj.CampaignId__c);
        //END>> 30/05/22 costanzo.lomele@webresults.it #fix for campagne performance tests
        this.campaignMembers = [SELECT ContractReference__c, PromoCommercialCode__r.fullcode__c, Campaign.Name, Campaign.Description, Campaign.StaticTextMessageBill__c, Campaign.Channel__c 
                                FROM CampaignMember 
                                WHERE CampaignId IN :campaignIds AND ContractReference__c != null AND isWsBollettaInvoked__c = false AND Campaign.Channel__c INCLUDES ('Bolletta') WITH SECURITY_ENFORCED];
    }

    public Iterable<CampaignMember> start(Database.BatchableContext bc) {
        return this.campaignMembers;
    }

    public void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest> wsReqList = new List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest>();

        for (CampaignMember cm : scope) {
                HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest wsReq = new HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest();
                wsReq.campaignId = cm.CampaignId;
                wsReq.campaignName = cm.Campaign.Name;
                wsReq.campaignDescription = cm.Campaign.Description;
                wsReq.comunicationText = cm.Campaign.StaticTextMessageBill__c == null ? cm.PromoCommercialCode__r.fullcode__c : cm.Campaign.StaticTextMessageBill__c + ' ' + cm.PromoCommercialCode__r.fullcode__c;
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
        for(Commercial_Code_Batch_Context__c curObj : this.batchCSContext) curObj.BollettaDone__c = true;
        update this.batchCSContext;
    }
}