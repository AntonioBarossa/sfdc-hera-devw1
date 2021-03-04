/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/02/2020
* @description HDT_QR_CampaignMember – Contains queries for CampaignMember
* @history Keltin Mesonjesi – 27/02/2020 – Created class
*/
public inherited sharing class HDT_QR_CampaignMember {
    
    public List<CampaignMember> getActiveCampaignsByContact(String contactId){
        return [
            SELECT 
            CampaignId,
            Campaign.Name,
            Campaign.Status,
            Campaign.Channel__c,
            Campaign.EndDate
            FROM CampaignMember
            where ContactId = :contactId
            AND Campaign.isActive = true
            WITH SECURITY_ENFORCED];
    }

    public List<CampaignMember> getActiveCampaignsByLead(String leadId){
        return [
            SELECT 
            CampaignId,
            Campaign.Name,
            Campaign.Status,
            Campaign.Channel__c,
            Campaign.EndDate
            FROM CampaignMember
            where LeadId = :leadId
            AND Campaign.isActive = true
            WITH SECURITY_ENFORCED];
    }

    public List<CampaignMember> getActiveCampaignsByContacts(List<Contact> contacts){
        return [
            SELECT
            CampaignId,
            Campaign.Name,
            Campaign.Status,
            Campaign.Channel__c,
            Campaign.EndDate
            FROM
            CampaignMember
            where ContactId IN :contacts
            AND Campaign.isActive = true
            WITH SECURITY_ENFORCED];
    }
}
