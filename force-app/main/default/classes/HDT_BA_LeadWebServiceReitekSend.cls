public with sharing class HDT_BA_LeadWebServiceReitekSend implements Database.Batchable<sObject>, Database.Stateful {

   // public List<Lead> leads= new List<Lead>();
    String macroactivity= null;
    String campaignId = '';
    public HDT_BA_LeadWebServiceReitekSend(){
 
        List<Campaign> campaign= HDT_QR_Campaign.getCampaignIds('LEAD CALLBACK');
        String macroactivity= null;

        if(campaign.size()>1){
            for(Campaign c: campaign){
                  //  d = c.CreatedDate;
                    macroactivity= c.MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
            }
        }else{
            campaignId = campaign[0].Id;
            macroactivity= campaign[0].MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c;
        }
    }


    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime dt = system.now();
        System.debug('dt value: '+ dt);
        Date dtYesterday = system.today().addDays(-1);
        System.debug('dtYesterday value: '+ dtYesterday);
        String query = 'SELECT Id, CreatedDate,lead.MobilePhone , Status, LeadSource FROM CampaignMember Where campaignId = :campaignId AND LeadId != null AND lead.ContactDate__c != null AND lead.isSendToReitek__c = false AND lead.ContactDate__c > :dtYesterday AND lead.ContactDate__c < :dt' ;
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        List<Lead> leadList = new List<Lead>();
        for(CampaignMember cm : scope){
            HDT_WS_InvioNumerazioni.callService(macroactivity, cm.lead.MobilePhone);
            leadList.add(new Lead(id=cm.leadId,isSendToReitek__c=true));
        }
        update leadList;
    }
    public void finish(Database.BatchableContext bc){
       // update leads;
       System.debug('MethodNotNecessaryButRequired');
    }
}
