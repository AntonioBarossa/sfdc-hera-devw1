public inherited sharing class HDT_LC_CampaignsController {
    @AuraEnabled(cacheable=true)
    public static List <CampaignMember> getCampaigns(String id, String objectName) {
        String objIdField;
        if (objectName == 'Contact') {
            //return all active campaigns related to this Contact
            return [SELECT CampaignId, Campaign.Name, Campaign.Status, Campaign.Channel__c, Campaign.EndDate FROM CampaignMember where ContactId = :id AND Campaign.isActive = true];
        } else if(objectName == 'Lead') {
            //return all active campaigns related to this Lead
            return [SELECT CampaignId, Campaign.Name, Campaign.Status, Campaign.Channel__c, Campaign.EndDate FROM CampaignMember where LeadId = :id AND Campaign.isActive = true];
        } else if(objectName == 'Account') {
            //return all active campaigns related to all contacts related to this Account
            List<Contact> contacts = [Select Id from Contact where AccountId = :id];
            return [SELECT CampaignId, Campaign.Name, Campaign.Status, Campaign.Channel__c, Campaign.EndDate FROM CampaignMember where ContactId IN :contacts AND Campaign.isActive = true];
        } else {
            return null;
        }
    }
}
