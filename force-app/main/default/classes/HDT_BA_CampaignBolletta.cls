public with sharing class HDT_BA_CampaignBolletta implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ContractReference__c, PromoCommercialCode__r.fullcode__c, Campaign.Name, Campaign.Description, Campaign.StaticTextMessageBill__c, Campaign.Channel__c'
        +' FROM CampaignMember'
        +' WHERE ContractReference__c != null'
        +' AND isWsBollettaInvoked__c = false'
        +' AND PromoCommercialCode__c != null'
        +' AND Campaign.Channel__c = \'Bolletta\''
        +' WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> context) {
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest> wsReqList = new List<HDT_WS_CampaignBolletta.HDT_WS_CampaignBollettaRequest>();

        for (sObject obj : context) {
                CampaignMember cm = (CampaignMember)obj;
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
                for (sObject obj : context) {
                    CampaignMember cm = (CampaignMember)obj;
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
        System.debug('-------- finish batch HDT_BA_CampaignBolletta');
        /*
        List<CampaignMember> remainingContext = [
            SELECT ContractReference__c, PromoCommercialCode__r.fullcode__c, Campaign.Name, Campaign.Description, Campaign.StaticTextMessageBill__c, Campaign.Channel__c 
            FROM CampaignMember 
            WHERE ContractReference__c != null
            AND isWsBollettaInvoked__c = false
            AND PromoCommercialCode__c != null
            AND Campaign.Channel__c = 'Bolletta'
            WITH SECURITY_ENFORCED];
        if (remainingContext.size() > 0) {
            System.scheduleBatch(new HDT_BA_CampaignBolletta(), 'HDT_BA_CampaignBolletta', 1, 100);
        }
        */
    }
}