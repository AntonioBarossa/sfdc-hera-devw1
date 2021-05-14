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

    public List<CampaignMember> getCampaignsFilteredByContacts(List<String> contacts){
        Date d = Date.today();
        return [
            SELECT
            Id,
            CampaignId,
            Campaign.Name,
            Status,
            Campaign.Category__c,
            Campaign.Channel__c,
            Campaign.EndDate,
            Contact.Name,
            Campaign.Required__c,
            Campaign.ProcessType__c,
            Campaign.CaseCategory__c,
            Campaign.CaseSubCategory__c
            FROM
            CampaignMember
            WHERE ContactId IN :contacts
            AND Campaign.isActive = true
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            AND HasResponded = false
            WITH SECURITY_ENFORCED
            ORDER BY Campaign.Required__c DESC, Campaign.Priority__c ASC
        ];
    }
    public List<CampaignMember> filterCampaignsByCategory(List<String> contacts, String category){
        Date d = Date.today();
        return [
        SELECT
            Id,
            CampaignId,
            Campaign.Name,
            Status,
            Campaign.Category__c,
            Campaign.Channel__c,
            Campaign.EndDate,
            Contact.Name,
            Campaign.Required__c,
            Campaign.ProcessType__c,
            Campaign.CaseCategory__c,
            Campaign.CaseSubCategory__c
            FROM
            CampaignMember
            WHERE ContactId IN :contacts
            AND Campaign.isActive = true
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            AND HasResponded = false
            AND Campaign.Category__c = :category
            WITH SECURITY_ENFORCED
            ORDER BY Campaign.Required__c DESC, Campaign.Priority__c ASC
        ];
    }

    public List<CampaignMember> filterCampaignsByCategoryAndChannel(List<String> contacts, String category, String channel){
        Date d = Date.today();

        return [
        SELECT
            Id,
            CampaignId,
            Campaign.Name,
            Status,
            Campaign.Category__c,
            Campaign.Channel__c,
            Campaign.EndDate,
            Contact.Name,
            Campaign.Required__c,
            Campaign.ProcessType__c,
            Campaign.CaseCategory__c,
            Campaign.CaseSubCategory__c
            FROM
            CampaignMember
            WHERE ContactId IN :contacts
            AND Campaign.isActive = true
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            AND HasResponded = false
            AND Campaign.Category__c = :category
            AND Campaign.Channel__c INCLUDES (:channel)
            WITH SECURITY_ENFORCED
            ORDER BY Campaign.Required__c DESC, Campaign.Priority__c ASC
        ];
    }

    public List<CampaignMember> getUnassignedCampaignMembers(String campaignId){
        return [
            SELECT 
            Id
            FROM CampaignMember 
            WHERE CampaignId = :campaignId 
            AND Agency__c = NULL
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Account> getAccountsforCampaignMembers(){
        return [
            SELECT 
            Id,
            Name
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];
    }
    public CampaignMember getAccountAndCampaign(String campaignMemberId) {
        return [
            SELECT
            Id,
            ContactId, 
            LeadId, 
            CampaignId, 
            GenericField1__c 
            FROM CampaignMember 
            WHERE Id = :campaignMemberId
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<CampaignMember> getCampaignMembersByContacts(List<Contact> contacts){
        return [
            SELECT
            CampaignId
            FROM
            CampaignMember
            where ContactId IN :contacts
            WITH SECURITY_ENFORCED];
    }

    
    public List<CampaignMember> getContactsWithinDistance(Decimal latitude, Decimal longitude, Decimal distanceKm) {
        Date d = Date.today();
        return [
            SELECT CampaignId, 
            Campaign.Name, 
            Contact.FirstName, 
            Contact.LastName, 
            Contact.Phone, 
            Contact.Email, 
            Contact.MailingAddress 
            FROM CampaignMember 
            WHERE CampaignId IN 
            (SELECT Id FROM Campaign WHERE  Channel__c INCLUDES ('Door to Door') AND IsActive = true) 
            AND DISTANCE(Contact.MailingAddress, GEOLOCATION(:latitude, :longitude), 'km') < :distanceKm
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            WITH SECURITY_ENFORCED
        ];
    }

    public List<CampaignMember> getLeadsWithinDistance(Decimal latitude, Decimal longitude, Decimal distanceKm) {
        Date d = Date.today();
        return [
            SELECT CampaignId, 
            Campaign.Name, 
            Lead.FirstName, 
            Lead.LastName, 
            Lead.Phone, 
            Lead.Email, 
            Lead.Address 
            FROM CampaignMember 
            WHERE CampaignId IN 
            (SELECT Id FROM Campaign WHERE  Channel__c INCLUDES ('Door to Door') AND IsActive = true) 
            AND DISTANCE(Lead.Address, GEOLOCATION(:latitude, :longitude), 'km') < :distanceKm
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            WITH SECURITY_ENFORCED
        ];
    }
}