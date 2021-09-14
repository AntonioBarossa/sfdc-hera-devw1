/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 25/06/2021
* @description HDT_BA_PaperCampaignClosing
* @history Lorenzo – 25/06/2021 – created class
*/
public with sharing class HDT_BA_PaperCampaignClosing implements Database.Batchable<sObject> {


    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_CampaignMember campSRV = new HDT_SRV_CampaignMember();
    public String paperProcessingId;
    public date daten = System.today();
    public list<String> contentVersionIdList = new List<String>();

    public HDT_BA_PaperCampaignClosing(String paperProcessingId) {
        this.paperProcessingId = paperProcessingId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT campaignId,Status,contactId FROM CampaignMember WHERE PaperProcess__c = :paperProcessingId AND status != \'Gestito da CRM\' AND contactId != null WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
        List<PaperCommunication__C> ppWrapList = new List<PaperCommunication__C>();
        for(CampaignMember cm : scope) {
            PaperCommunication__C pc = new PaperCommunication__c();
            pc.PaperProcessing__c = this.paperProcessingId;
            pc.Contact__c = cm.ContactId;
            pc.Campaign__c = cm.CampaignId;
            pc.Date__c = this.daten;
            pc.CommunicationId__c=this.paperProcessingId+'_'+cm.id;
            cm.status = 'Gestito da CRM';
            ppWrapList.add(pc);
            
        }
        HDT_SRV_PaperCommunication.insertRecords(ppWrapList);
        campSRV.updateRecords(scope);
    }

    public void finish(Database.BatchableContext bc){

    }
}