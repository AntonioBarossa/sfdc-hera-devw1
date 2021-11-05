public with sharing class HDT_BA_DeactivateCampaign implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public List<Id> campaignIdList;
    public HDT_BA_DeactivateCampaign(List<Id> campaignIdList) {
        this.campaignIdList = campaignIdList;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //return new campaignMembers
        String query = 'SELECT Id, Name FROM Campaign WHERE Id IN :campaignIdList';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Campaign> scope) {
        HDT_WS_DeactivateCampaign.wrapResponseGetData response = new HDT_WS_DeactivateCampaign.wrapResponseGetData();
        for(Campaign c : scope) {
            //send WS request
            response = HDT_WS_DeactivateCampaign.callDeactivateCampaign(c.Id);
        }
        System.debug(response);
    }

    public void finish(Database.BatchableContext bc){
        System.debug('-------- finish batch');
    }
}
