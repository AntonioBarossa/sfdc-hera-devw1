public with sharing class HDT_BA_DeactivateCampaign implements Database.Batchable<SObject> {
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
        List<HDT_WS_DeactivateCampaign.wrapRequestObject> requestList = new List<HDT_WS_DeactivateCampaign.wrapRequestObject>();
        //prepare request list
        for(Campaign c : scope) {
            HDT_WS_DeactivateCampaign.wrapRequestObject req = new HDT_WS_DeactivateCampaign.wrapRequestObject();
            req = HDT_WS_DeactivateCampaign.requestDeactivateCampaign(c.Id);
            requestList.add(req);        
        }

        //send WS request List
        HDT_WS_DeactivateCampaign.wrapResponseGetData response = new HDT_WS_DeactivateCampaign.wrapResponseGetData();
        response = HDT_WS_DeactivateCampaign.callDeactivateCampaign(requestList);
        System.debug(response);
      
    }

    public void finish(Database.BatchableContext bc){
        System.debug('-------- finish batch');
    }
}
