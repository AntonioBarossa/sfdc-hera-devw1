/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/02/2020
* @description HDT_QR_CampaignMember – Contains queries for CampaignMember
* @history Keltin Mesonjesi – 27/02/2020 – Created class
*/
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class HDT_QR_CampaignMember {
    
    /**
    * @description getActiveCampaignsByContact
    * @param contactId
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getActiveCampaignsByContact(String contactId){

        return [SELECT id, CampaignId, Campaign.Name, Campaign.Status, Campaign.Channel__c, Campaign.EndDate, Status FROM CampaignMember 
                WHERE ContactId = :contactId AND Campaign.isActive = true WITH SECURITY_ENFORCED];
    }
    
    public List<CampaignMember> getCampaignsByContactPartner(String contactId, User currentUser){

        Date tday = System.Date.today();
        String channel = currentUser.Profile.Name.equalsIgnoreCase('Hera Teleseller Partner User') ? 'Telefonico Outbound' : 'Door to Door';

        return [SELECT Id, CampaignId, Campaign.Name, Campaign.Status, Campaign.Channel__c, Campaign.EndDate, Status FROM CampaignMember 
                WHERE ContactId = :contactId AND Campaign.isActive = true AND (Campaign.Status = 'In Corso' OR Campaign.Status = 'Pianificata') AND HasResponded = false AND Campaign.StartDate <= :tday AND Campaign.Channel__c includes (:channel) WITH SECURITY_ENFORCED];
    }

    /**
    * @description getActiveCampaignsByLead
    * @param leadId
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getActiveCampaignsByLead(String leadId){
        return [SELECT CampaignId, Campaign.Name, Campaign.Status, Campaign.Channel__c, Campaign.EndDate, Status FROM CampaignMember 
                WHERE LeadId = :leadId AND Campaign.isActive = true WITH SECURITY_ENFORCED];
    }

    public List<CampaignMember> getCampaignsByLeadPartner(String leadId, User currentUser){
        
        Date tday = System.Date.today();
        String channel = currentUser.Profile.Name.equalsIgnoreCase('Hera Teleseller Partner User') ? 'Telefonico Outbound' : 'Door to Door';

        return [SELECT CampaignId, Campaign.Name, Campaign.Status, Campaign.Channel__c, Campaign.EndDate, Status FROM CampaignMember 
                WHERE LeadId = :leadId AND Campaign.isActive = true AND (Campaign.Status = 'In Corso' OR Campaign.Status = 'Pianificata') AND HasResponded = false AND Campaign.StartDate <= :tday AND Campaign.Channel__c includes (:channel) WITH SECURITY_ENFORCED];
    }

    /**
    * @description getActiveCampaignsByContacts
    * @param contacts
    * @return List<CampaignMember>
    */
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

    /**
    * @description getCampaignsFilteredByContacts
    * @param contacts
    * @return List<CampaignMember>
    */
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
            Campaign.CaseSubCategory__c,
            Campaign.FlowType__c
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

 /**
    * @description getCampaignsFilteredByContactsWithStatus
    * @param contacts
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getCampaignsFilteredByContactsWithStatus(List<String> contacts){
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
            Campaign.CaseSubCategory__c,
            Campaign.FlowType__c
            FROM
            CampaignMember
            WHERE ContactId IN :contacts
            AND Campaign.isActive = true
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            AND HasResponded = false
            AND (Campaign.Status = 'In Corso' OR Campaign.Status = 'Pianificata') 
            WITH SECURITY_ENFORCED
            ORDER BY Campaign.Required__c DESC, Campaign.Priority__c ASC
        ];
    }

    /**
    * @description filterCampaignsByCategory
    * @param contacts
    * @param category
    * @return List<CampaignMember>
    */
    public List<CampaignMember> filterCampaignsByCategory(List<String> contacts, String category){
        Date d = Date.today();
        return [
        SELECT
            Id,
            CampaignId,
            Campaign.Name,
            Status,
            Campaign.Status,
            Campaign.Category__c,
            Campaign.Channel__c,
            Campaign.EndDate,
            Contact.Name,
            Campaign.Required__c,
            Campaign.ProcessType__c,
            Campaign.CaseCategory__c,
            Campaign.CaseSubCategory__c,
            Campaign.FlowType__c
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

/**
    * @description filterCampaignsByCategoryWithStatus
    * @param contacts
    * @param category
    * @return List<CampaignMember>
    */
    public List<CampaignMember> filterCampaignsByCategoryWithStatus(List<String> contacts, String category){
        Date d = Date.today();
        return [
        SELECT
            Id,
            CampaignId,
            Campaign.Name,
            Status,
            Campaign.Status,
            Campaign.Category__c,
            Campaign.Channel__c,
            Campaign.EndDate,
            Contact.Name,
            Campaign.Required__c,
            Campaign.ProcessType__c,
            Campaign.CaseCategory__c,
            Campaign.CaseSubCategory__c,
            Campaign.FlowType__c
            FROM
            CampaignMember
            WHERE ContactId IN :contacts
            AND Campaign.isActive = true
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            AND HasResponded = false
            AND Campaign.Category__c = :category
            AND (Campaign.Status = 'In Corso' OR Campaign.Status = 'Pianificata') 
            WITH SECURITY_ENFORCED
            ORDER BY Campaign.Required__c DESC, Campaign.Priority__c ASC

        ];
    }


    /**
    * @description filterCampaignsByCategoryAndChannel
    * @param contacts
    * @param category
    * @param channel
    * @return List<CampaignMember>
    */
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
            Campaign.CaseSubCategory__c,
            Campaign.FlowType__c
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

/**
    * @description filterCampaignsByCategoryAndChannelWithStatus
    * @param contacts
    * @param category
    * @param channel
    * @return List<CampaignMember>
    */
    public List<CampaignMember> filterCampaignsByCategoryAndChannelWithStatus(List<String> contacts, String category, String channel){
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
            Campaign.CaseSubCategory__c,
            Campaign.FlowType__c
            FROM
            CampaignMember
            WHERE ContactId IN :contacts
            AND Campaign.isActive = true
            AND Campaign.StartDate <= :d
            AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
            AND HasResponded = false
            AND Campaign.Category__c = :category
            AND Campaign.Channel__c INCLUDES (:channel)
            AND (Campaign.Status = 'In Corso' OR Campaign.Status = 'Pianificata') 
            
            WITH SECURITY_ENFORCED
            ORDER BY Campaign.Required__c DESC, Campaign.Priority__c ASC
        ];
    }


    /**
    * @description getUnassignedCampaignMembers
    * @param campaignId
    * @return List<CampaignMember>
    */
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

    /**
    * @description getUnassignedCampaignMembersSlice
    * @param campaignId
    * @param amount
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getUnassignedCampaignMembersSlice(String campaignId, Integer amount){
        return [
            SELECT 
            Id
            FROM CampaignMember 
            WHERE CampaignId = :campaignId 
            AND Agency__c = NULL
            WITH SECURITY_ENFORCED
            LIMIT :amount
        ];
    }

    /**
    * @description getAccountsforCampaignMembers
    * @return List<Account>
    */
    public List<Account> getAccountsforCampaignMembers(){
        return [
            SELECT 
            Id,
            Name
            FROM Account
            WHERE RecordType.DeveloperName = 'HDT_RT_Partner' AND owner.Name ='Outbound Channel Manager'
            WITH SECURITY_ENFORCED ORDER BY Name asc
        ];
    }

    /**
    * @description getAccountAndCampaign
    * @param campaignMemberId
    * @return CampaignMember
    */
    public CampaignMember getAccountAndCampaign(String campaignMemberId) {
        return [
            SELECT
            Id,
            LeadId, 
            CampaignId, 
            GenericField1__c,
            Campaign.ProcessType__c,
            Campaign.Name,
            ContactId,
            Contact.AccountId,
            Contact.Name
            FROM CampaignMember 
            WHERE Id = :campaignMemberId
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getCampaignMembersByContacts
    * @param contacts
    * @return List<CampaignMember>
    */
    public static List<CampaignMember> getCampaignMembersByContacts(List<Contact> contacts){
        return [
            SELECT
            CampaignId
            FROM
            CampaignMember
            where ContactId IN :contacts
            WITH SECURITY_ENFORCED];
    }

    /**
    * @description getByEcid
    * @param ecid
    * @return CampaignMember
    */
    public CampaignMember getByEcid(String ecid) {
        if (string.isBlank(ecid)) {
            return null;
        }
        else{
            List<CampaignMember> cmList = [
            SELECT
            Id, 
            Status  
            FROM CampaignMember 
            WHERE Ecid__c = :ecid
            AND isToSendStatusReitek__c = true
            WITH SECURITY_ENFORCED
            ];
            return cmList != null && !cmList.isEmpty() ? cmList[0] : null;
        }

    }

    /**
    * @description getByEcid
    * @param id
    * @return CampaignMember
    */
    public CampaignMember getEcidById(String id) {
        List<CampaignMember> cmList = [
            SELECT
            Id,
            reitekAgentUserId__c , 
            Ecid__c
            FROM CampaignMember 
            WHERE id = :id
            WITH SECURITY_ENFORCED
        ];
        return cmList != null && !cmList.isEmpty() ? cmList[0] : null;
    }

    /**
    * @description getContactsWithinDistance
    * @param latitude
    * @param longitude
    * @param distanceKm
    * @return CampaignMember
    */
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

    /**
    * @description getLeadsWithinDistance
    * @param latitude
    * @param longitude
    * @param distanceKm
    * @return CampaignMember
    */
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

    /**
    * @description getMembersByAccountAndCampaign
    * @param accountIds
    * @param campaignIds
    * @return CampaignMember
    */
    public List<CampaignMember> getMembersByAccountAndCampaign(List<String> accountIds, List<String> campaignIds) {
        return [
            SELECT Id,
            Contact.AccountId,
            CampaignId,
            Status
            FROM CampaignMember 
            WHERE HasResponded = false 
            AND Contact.AccountId IN :accountIds
            AND CampaignId IN :campaignIds
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getCampaignMembersForPaperProcessing
    * @param paperProcessingId
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getCampaignMembersForPaperProcessing(String paperProcessingId) {
        return [
            SELECT Id,
            PaperProcess__c,
            ContactId, 
            LeadId,
            Contact.Account.CustomerCode__c,
            Contact.Company__c, 
            Lead.Company__c, 
            Contact.FirstName, 
            Contact.LastName,
            Lead.FirstName, 
            Lead.LastName,
            Contact.FiscalCode__c,
            Lead.FiscalCode__c,
            Contact.VATNumber__c,
            Lead.VATNumber__c,  
            Contact.MailingStreetName__c,
            Lead.Street,
            Contact.MailingStreetNumber__c,
            Lead.StreetNumber__c,
            Contact.MailingPostalCode,
            Lead.PostalCode, 
            Contact.MailingCity, 
            Lead.City, 
            Contact.MailingState, 
            Lead.State,
            Contact.MailingCountry, 
            Lead.Country,  
            ContractReference__c,
            Campaign.PaperCampaignParameter__r.LetterType__c,
            Campaign.PaperCampaignParameter__r.ShippingMode__c,
            Campaign.PaperCampaignParameter__r.Aggregation__c,
            Campaign.PaperCampaignParameter__r.Lot__c,
            Campaign.PaperCampaignParameter__r.LotDate__c,
            Campaign.PaperCampaignParameter__r.Field2__c,
            Campaign.PaperCampaignParameter__r.Field3__c,
            Campaign.PaperCampaignParameter__r.Field4__c,
            Campaign.PaperCampaignParameter__r.Field5__c,
            Campaign.PaperCampaignParameter__r.Field6__c,
            Campaign.PaperCampaignParameter__r.Field7__c,
            Campaign.PaperCampaignParameter__r.Field8__c,
            Campaign.PaperCampaignParameter__r.Field9__c,
            Campaign.PaperCampaignParameter__r.Field10__c,
            Campaign.PaperCampaignParameter__r.Field11__c,
            Campaign.PaperCampaignParameter__r.Field12__c,
            Campaign.PaperCampaignParameter__r.Field13__c,
            Campaign.PaperCampaignParameter__r.Field14__c,
            Campaign.PaperCampaignParameter__r.Field15__c,
            Campaign.PaperCampaignParameter__r.Field16__c,
            Campaign.PaperCampaignParameter__r.Field17__c,
            Campaign.PaperCampaignParameter__r.Field18__c,
            Campaign.PaperCampaignParameter__r.Field19__c,
            Campaign.PaperCampaignParameter__r.Field20__c,
            Campaign.PaperCampaignParameter__r.Field21__c,
            Campaign.PaperCampaignParameter__r.Field22__c,
            Campaign.PaperCampaignParameter__r.Field23__c,
            Campaign.PaperCampaignParameter__r.Field24__c,
            Campaign.PaperCampaignParameter__r.Field25__c,
            Campaign.PaperCampaignParameter__r.Field26__c,
            Campaign.PaperCampaignParameter__r.Field27__c,
            Campaign.PaperCampaignParameter__r.Field28__c,
            Campaign.PaperCampaignParameter__r.Field29__c,
            Campaign.PaperCampaignParameter__r.Field30__c,
            Campaign.PaperCampaignParameter__r.Field31__c,
            Campaign.PaperCampaignParameter__r.Field32__c,
            Campaign.PaperCampaignParameter__r.Field33__c,
            Campaign.PaperCampaignParameter__r.Field34__c,
            Campaign.PaperCampaignParameter__r.Field35__c,
            Campaign.PaperCampaignParameter__r.Field36__c,
            Campaign.PaperCampaignParameter__r.Field37__c,
            Campaign.PaperCampaignParameter__r.Field38__c,
            Campaign.PaperCampaignParameter__r.Field39__c,
            Campaign.PaperCampaignParameter__r.Field40__c
            FROM CampaignMember 
            WHERE CampaignId 
            IN (SELECT Campaign__c FROM PaperProcessing__c WHERE id =: paperProcessingId)
            AND PaperProcess__c = ''
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getMembersByCampaign
    * @param campaignId
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getMembersByCampaign(String campaignId) {
        return [
            SELECT Id,
            Name,
            Agency__c
            FROM CampaignMember
            WHERE CampaignId = :campaignId
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getCampaignMemberByCampaingAndContact
    * @param campaign
    * @param contact
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getCampaignMemberByCampaingAndContact(String campaign, String contact){
        SObjectAccessDecision securityDecision = 
         Security.stripInaccessible(AccessType.READABLE, [
            SELECT Id,
            Contact.AccountId,
            CampaignId,
            Status,
            Ecid__c
            FROM CampaignMember 
            WHERE ContactId = :contact
            AND CampaignId = :campaign
        ]);
        return securityDecision.getRecords();
        //System.debug(securityDecision.getRemovedFields());
    }

    /**
    * @description getCampaignMemberByCampaingAndContactInBulk
    * @param campaign
    * @param contact
    * @return List<CampaignMember>
    */
    public List<CampaignMember> getCampaignMemberByCampaingAndContactInBulk(List<String> campaign, List<String> contact){
        return [
            SELECT Id,
            ContactId,
            Contact.AccountId,
            CampaignId,
            RelatedActivity__c,
            NumberingValidityStartDate__c,
            Status
            FROM CampaignMember 
            WHERE ContactId IN :contact
            AND CampaignId IN :campaign
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getCampaignMemberByCampaingAndContactInBulk
    * @param accountIds
    * @param campaignChannel
    * @return List<CampaignMember>
    */
    public static List<CampaignMember> getSiblingMembersByAccountId(List<String> accountIds, String campaignChannel) {
        /* List<CampaignMember> allMembers = [
            SELECT CampaignId 
            FROM CampaignMember 
            WHERE Campaign.Required__c = true
            AND Campaign.Channel__c = :campaignChannel
            AND Contact.AccountId IN :accountIds
            WITH SECURITY_ENFORCED
        ];
        List<String> cmpList = new List<String>();
        for (CampaignMember cm : allMembers) {
            if (!cmpList.contains(cm.CampaignId)) {
                cmpList.add(cm.CampaignId);
            }
        }
        return [
            SELECT Id
            FROM CampaignMember
            WHERE CampaignId IN :cmpList
            AND HasResponded = false
            AND Status != 'Non Proposto Auto'
            WITH SECURITY_ENFORCED
        ]; */
        Date d = Date.today();
        return [SELECT Id FROM CampaignMember WHERE Contact.AccountId IN :accountIds
                    AND Campaign.Channel__c = :campaignChannel
                    AND Campaign.Required__c = true
                    AND Campaign.Category__c = 'Campagna CRM'
                    AND Campaign.isActive = true
                    AND Campaign.StartDate <= :d
                    AND (Campaign.EndDate >= :d OR Campaign.EndDate = NULL)
                    AND Status != 'Non Proposto Auto'
                    AND HasResponded = false WITH SECURITY_ENFORCED];
    }

    public CampaignMember getRecordById(String campaignMemberId) {
        return [
            SELECT
            Id,
            ContactId, 
            LeadId
            FROM CampaignMember 
            WHERE Id = :campaignMemberId
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<CampaignMember> getCampMembByActivity(String actId){

        List<CampaignMember> campMembList = [SELECT Id, Status, Campaign.PositiveOutcomeDefaultStatus__c FROM CampaignMember WHERE RelatedActivity__c = :actId WITH SECURITY_ENFORCED];
        return campMembList;
    }
    
}