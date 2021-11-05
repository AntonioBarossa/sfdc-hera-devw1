/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 25/06/2021
* @description HDT_BA_PaperCampaignTargeting
* @history Lorenzo – 25/06/2021 – created class
*/
public with sharing class HDT_BA_PaperCampaignTargeting implements Database.Batchable<sObject> {


    private static HDT_QR_CampaignMember campaignMemberQr = new HDT_QR_CampaignMember();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_CampaignMember campSRV = new HDT_SRV_CampaignMember();
    public List<PaperProcessing__c> paperProcessingList = new List<PaperProcessing__c>();
    public List<String> campaignIds = new List<String>();
   // public List<CampaignMember> campaignMembers;
    public String contentVersionId;
    public list<String> contentVersionIdList = new List<String>();
    private Map<String,String> campaignIdPaperId = new Map<String,String>();


    public HDT_BA_PaperCampaignTargeting(List<PaperProcessing__c> paperProcessingList) {
        this.paperProcessingList = paperProcessingList;
        for (PaperProcessing__c p : paperProcessingList) {
            this.campaignIds.add(p.Campaign__c);
            this.campaignIdPaperId.put(p.Campaign__c, p.Id);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id,PaperProcess__c,ContactId,LeadId,Contact.Account.CustomerCode__c,Contact.Company__c,Lead.Company__c,Contact.FirstName,Contact.LastName,Lead.FirstName,Lead.LastName,Contact.FiscalCode__c,Lead.FiscalCode__c,Contact.VATNumber__c,Lead.VATNumber__c,Contact.MailingStreetName__c,Lead.Street,Contact.MailingStreetNumber__c,Lead.StreetNumber__c,Contact.MailingPostalCode,Lead.PostalCode,Contact.MailingCity,Lead.City,Contact.MailingState,Lead.State,Contact.MailingCountry,Lead.Country,ContractReference__c,Campaign.PaperCampaignParameter__r.LetterType__c,Campaign.PaperCampaignParameter__r.ShippingMode__c,Campaign.PaperCampaignParameter__r.Aggregation__c,Campaign.PaperCampaignParameter__r.Lot__c,Campaign.PaperCampaignParameter__r.LotDate__c,Campaign.PaperCampaignParameter__r.Field2__c,Campaign.PaperCampaignParameter__r.Field3__c,Campaign.PaperCampaignParameter__r.Field4__c,Campaign.PaperCampaignParameter__r.Field5__c,Campaign.PaperCampaignParameter__r.Field6__c,Campaign.PaperCampaignParameter__r.Field7__c,Campaign.PaperCampaignParameter__r.Field8__c,Campaign.PaperCampaignParameter__r.Field9__c,Campaign.PaperCampaignParameter__r.Field10__c,Campaign.PaperCampaignParameter__r.Field11__c,Campaign.PaperCampaignParameter__r.Field12__c,Campaign.PaperCampaignParameter__r.Field13__c,Campaign.PaperCampaignParameter__r.Field14__c,Campaign.PaperCampaignParameter__r.Field15__c,Campaign.PaperCampaignParameter__r.Field16__c,Campaign.PaperCampaignParameter__r.Field17__c,Campaign.PaperCampaignParameter__r.Field18__c,Campaign.PaperCampaignParameter__r.Field19__c,Campaign.PaperCampaignParameter__r.Field20__c,Campaign.PaperCampaignParameter__r.Field21__c,Campaign.PaperCampaignParameter__r.Field22__c,Campaign.PaperCampaignParameter__r.Field23__c,Campaign.PaperCampaignParameter__r.Field24__c,Campaign.PaperCampaignParameter__r.Field25__c,Campaign.PaperCampaignParameter__r.Field26__c,Campaign.PaperCampaignParameter__r.Field27__c,Campaign.PaperCampaignParameter__r.Field28__c,Campaign.PaperCampaignParameter__r.Field29__c,Campaign.PaperCampaignParameter__r.Field30__c,Campaign.PaperCampaignParameter__r.Field31__c,Campaign.PaperCampaignParameter__r.Field32__c,Campaign.PaperCampaignParameter__r.Field33__c,Campaign.PaperCampaignParameter__r.Field34__c,Campaign.PaperCampaignParameter__r.Field35__c,Campaign.PaperCampaignParameter__r.Field36__c,Campaign.PaperCampaignParameter__r.Field37__c,Campaign.PaperCampaignParameter__r.Field38__c,Campaign.PaperCampaignParameter__r.Field39__c,Campaign.PaperCampaignParameter__r.Field40__c FROM CampaignMember WHERE CampaignId IN :campaignIds and PaperProcess__c = null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<CampaignMember> scope) {
        //List<HDT_WRP_PaperProcessing> ppWrapList = new List<HDT_WRP_PaperProcessing>();
        List<CampaignMember> membersToUpdate = new List<CampaignMember>();
        for(CampaignMember cm : scope) { 
            cm.paperProcess__c = this.campaignIdPaperId.get(cm.CampaignId);
            membersToUpdate.add(cm);
        }
        campSRV.updateRecords(membersToUpdate);
    }

    public void finish(Database.BatchableContext bc){
        //ws call
        /*List<String> listIdToSend = new List<String>();
        listIdToSend.add(cv.id);*/
        HDT_UTL_PaperProcessing.exportFileNotTrigger(this.paperProcessingList);
       // String type = 'Comunicazione Cartacea';
       // String wsResponse = HDT_UTL_PaperProcessing.postPaperProcessing(filezipName, type, this.contentVersionId);
        //System.debug(wsResponse);
      //  System.debug('-------- finish batch');
    }
}