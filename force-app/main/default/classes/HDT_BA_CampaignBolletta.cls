public with sharing class HDT_BA_CampaignBolletta implements Database.Batchable<Commercial_Code_Batch_Context__c>, Database.AllowsCallouts {

    public Iterable<Commercial_Code_Batch_Context__c> start(Database.BatchableContext bc) {
        List<Commercial_Code_Batch_Context__c> context = [SELECT Id, CampaignId__c, CampaignMemberId__c
                                                    		FROM Commercial_Code_Batch_Context__c 
                                                    		WHERE CommercialCodeDone__c = TRUE AND BollettaDone__c = FALSE];
        return context;
    }

    public void execute(Database.BatchableContext BC, List<Commercial_Code_Batch_Context__c> context) {
        Set<String> campaignIds = new Set<String>();
        Set<String> campaignMemberIds = new Set<String>();
        for(Commercial_Code_Batch_Context__c curObj : context){
            campaignIds.add(curObj.CampaignId__c);
            campaignMemberIds.add(curObj.CampaignMemberId__c);
        }
        List<CampaignMember> scope = [SELECT ContractReference__c, PromoCommercialCode__r.fullcode__c, Campaign.Name, Campaign.Description, Campaign.StaticTextMessageBill__c, Campaign.Channel__c 
                                        FROM CampaignMember 
                                        WHERE Id IN :campaignMemberIds AND CampaignId IN :campaignIds AND ContractReference__c != null AND isWsBollettaInvoked__c = false AND Campaign.Channel__c INCLUDES ('Bolletta') WITH SECURITY_ENFORCED];
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
            System.debug(wsReqList);
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
        
        System.debug('@@@ deleting worked context');
        delete context;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('-------- finish batch');
        List<Commercial_Code_Batch_Context__c> remainingContext = [SELECT Id, CampaignId__c, CampaignMemberId__c
                                                    		        FROM Commercial_Code_Batch_Context__c 
                                                    		        WHERE CommercialCodeDone__c = TRUE AND BollettaDone__c = FALSE];
        if(remainingContext.size()>0) System.scheduleBatch(new HDT_BA_CampaignBolletta(), 'HDT_BA_CampaignBolletta', 1, 100);
    }
}