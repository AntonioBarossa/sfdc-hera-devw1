public with sharing class HDT_QBL_InvioNumerazioni implements Queueable, Database.AllowsCallouts {

    private List<Id> remainingIds;

    private String macroactivity;
    private String phonenumber;
    private Datetime callDateTime;
    private Id cmId;
    private Boolean callWs;

    public HDT_QBL_InvioNumerazioni(List<Id> idsToProcess) {

        this.cmId = idsToProcess.get(0);

        CampaignMember currentCM = [SELECT Id, PhoneNumber__c, Lead.ContactDate__c, Campaign.MacroActivityEasyCIM__r.Name, Campaign.ReitekIntegrationTechnology__c
                                    FROM CampaignMember 
                                    WHERE Id = :cmId and ReitekSendDate__c = null
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1];

        if(currentCM.Campaign.ReitekIntegrationTechnology__c == 'Web Service') this.callWs = true;
        else this.callWs = false;
        this.macroactivity = currentCM.Campaign.MacroActivityEasyCIM__r.Name;
        this.phonenumber = currentCM.PhoneNumber__c;
        this.callDateTime = currentCM.Lead.ContactDate__c;

        idsToProcess.remove(0);
        this.remainingIds = idsToProcess;
    }
    
    public void execute(QueueableContext context){
        if(this.callWs){
            HDT_WS_Response response = HDT_WS_InvioNumerazioni.callService(this.macroactivity, this.phonenumber, this.callDateTime, this.cmId);
            System.debug('@@@ reitek response ' + JSON.serializePretty(response));
            new HDT_SRV_CampaignMember().updateRecords(new List<CampaignMember>{new CampaignMember( Id = cmId, ReitekSendDate__c = Date.today() )});
        }
        else {
            if(remainingIds.size() > 0) System.enqueueJob(new HDT_QBL_InvioNumerazioni(this.remainingIds));
        }
    }
}
