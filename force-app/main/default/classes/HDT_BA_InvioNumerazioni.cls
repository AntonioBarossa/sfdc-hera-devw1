public with sharing class HDT_BA_InvioNumerazioni implements Database.Batchable<CampaignMember>, Database.AllowsCallouts {

    public Iterable<CampaignMember> start(Database.BatchableContext bc) {
        List<CampaignMember> context = [SELECT Id, PhoneNumber__c, Lead.ContactDate__c, Campaign.MacroActivityEasyCIM__r.Name, Campaign.ReitekIntegrationTechnology__c
                                            FROM CampaignMember
                                            WHERE ReitekSendDate__c = null AND Campaign.ReitekIntegrationTechnology__c = 'Web Service'
                                            WITH SECURITY_ENFORCED];
        System.debug('@@ HDT_BA_InvioNumerazioni context size: '+context.size());
        return context;
    }

    public void execute(Database.BatchableContext BC, List<CampaignMember> context) {
        for(CampaignMember curCm : context){
            String macroactivity = curCm.Campaign.MacroActivityEasyCIM__r.Name;
            String phonenumber = curCm.PhoneNumber__c;
            Datetime callDateTime = curCm.Lead.ContactDate__c;
            HDT_WS_Response response = HDT_WS_InvioNumerazioni.callService(macroactivity, phonenumber, callDateTime, curCm.Id);
            System.debug('@@ HDT_BA_InvioNumerazioni reitek resp: '+curCm.Id+' '+response);
        }
        for(CampaignMember curCm : context) curCm.ReitekSendDate__c = Date.today();
        HDT_UTL_DatabaseService.updateSObject(context);
    }

    public void finish(Database.BatchableContext bc){
        System.debug('@@ HDT_BA_InvioNumerazioni finish');
    }
}