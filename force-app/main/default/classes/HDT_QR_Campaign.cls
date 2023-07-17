/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 24/06/2021
* @description HDT_QR_Campaign
* @history Lorenzo – 24/06/2021 – created class
*/
public with sharing class HDT_QR_Campaign {
    
    public static List<Campaign> getCampaignChild(List<String> listId){
        return [Select IsDeleted, IsActive, FlowType__c, RecurringCampaign__c, Required__c, ExpectedRevenue, BudgetedCost, ActualCost, AmountAllOpportunities, AmountWonOpportunities, HierarchyAmountAllOpportunities, HierarchyAmountWonOpportunities, HierarchyExpectedRevenue, HierarchyBudgetedCost, HierarchyActualCost, StartDate, EndDate, LastActivityDate, DateNextGeneration__c, CodeValidityEndDate__c, CreatedDate, LastModifiedDate, SystemModstamp, LastViewedDate, LastReferencedDate, NumberSent, HierarchyNumberSent, MaxNumberEECodeUse__c, MaxNumberGASCodeUse__c, MaxNumberVASCodeUse__c, GenerationPeriod__c, Priority__c, CodeConventionQuantity__c, Id, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, HierarchyNumberOfLeads, HierarchyNumberOfConvertedLeads, HierarchyNumberOfContacts, HierarchyNumberOfResponses, HierarchyNumberOfOpportunities, HierarchyNumberOfWonOpportunities, Channel__c, ExpectedResponse, CampaignMemberPercentageAllocation__c, Type, Status, CompanyOwner__c, Category__c, Segment__c, AssignmentType__c, BillTypeMessage__c, CodeGenerationRule__c, CodeManagementModel__c, ReitekIntegrationTechnology__c, TargetingMode__c, Tipology__c, ProcessType__c, CaseCategory__c, CaseSubCategory__c, ParentId, CampaignImageId, OwnerId, CreatedById, LastModifiedById, CampaignMemberRecordTypeId, CampaignEasyCIM__c, OriginalCampaign__c, MacroActivityEasyCIM__c, CampaignMemberAssigment__c, SurveyCRM__c, ScriptConfig__c, Name, PrefixCode__c, IdCampaignIBMUnica__c, Target__c, StaticTextMessageBill__c, Description, TargetDescription__c, PositiveOutcomeDefaultStatus__c from Campaign where parentId IN :listId WITH SECURITY_ENFORCED];
    }

    public static List<Campaign> getCampaign(List<String> listId){
        return [Select PaperCampaignParameter__r.CostCenter__c,PaperCampaignParameter__r.LetterType__c,IsDeleted, IsActive, RecurringCampaign__c, Required__c, ExpectedRevenue, BudgetedCost, ActualCost, AmountAllOpportunities, AmountWonOpportunities, HierarchyAmountAllOpportunities, HierarchyAmountWonOpportunities, HierarchyExpectedRevenue, HierarchyBudgetedCost, HierarchyActualCost, StartDate, EndDate, LastActivityDate, DateNextGeneration__c, CodeValidityEndDate__c, CreatedDate, LastModifiedDate, SystemModstamp, LastViewedDate, LastReferencedDate, NumberSent, HierarchyNumberSent, MaxNumberEECodeUse__c, MaxNumberGASCodeUse__c, MaxNumberVASCodeUse__c, GenerationPeriod__c, Priority__c, CodeConventionQuantity__c, Id, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, HierarchyNumberOfLeads, HierarchyNumberOfConvertedLeads, HierarchyNumberOfContacts, HierarchyNumberOfResponses, HierarchyNumberOfOpportunities, HierarchyNumberOfWonOpportunities, Channel__c, ExpectedResponse, CampaignMemberPercentageAllocation__c, Type, Status, CompanyOwner__c, Category__c, Segment__c, AssignmentType__c, BillTypeMessage__c, CodeGenerationRule__c, CodeManagementModel__c, ReitekIntegrationTechnology__c, TargetingMode__c, Tipology__c, ProcessType__c, CaseCategory__c, CaseSubCategory__c, ParentId, CampaignImageId, OwnerId, CreatedById, LastModifiedById, CampaignMemberRecordTypeId, CampaignEasyCIM__c, OriginalCampaign__c, MacroActivityEasyCIM__c, CampaignMemberAssigment__c, SurveyCRM__c, ScriptConfig__c, Name, PrefixCode__c, IdCampaignIBMUnica__c, Target__c, StaticTextMessageBill__c, Description, TargetDescription__c from Campaign where id IN :listId WITH SECURITY_ENFORCED];
    }

    public Campaign getRecordById(String id) {
        return [
            SELECT 
            Id,
            Name,
         //   LavorazioneFUB__c,
            AssignmentType__c
            FROM Campaign
            where Id = :id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public static List<Campaign> getCampaignIds(String name) {
        return [
            SELECT 
            Id,
            Name,
         //   LavorazioneFUB__c,
            MacroActivityEasyCIM__c,
            MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c,
            AssignmentType__c
            FROM Campaign
            where Name = :name
        //    WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
    public List<Campaign> getOutboundCampaigns() {
        Date d = Date.today();
        return [
            SELECT 
            Id,
            Name
            FROM Campaign
            WHERE isActive = true
            AND StartDate <= :d
            AND (EndDate >= :d OR EndDate = NULL)
            AND Category__c = 'Campagna Outbound'
            AND Channel__c INCLUDES ('Telefonico Outbound')
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Campaign> getOutboundCampaignsLead() {
        Date d = Date.today();
        return [
            SELECT 
            Id,
            Name
            FROM Campaign
            WHERE isActive = true
            AND StartDate <= :d
            AND (EndDate >= :d OR EndDate = NULL)
            AND Category__c = 'Campagna Outbound'
            AND Channel__c INCLUDES ('Telefonico Outbound')
            AND AssignmentType__c = 'Su Base Lead'
            AND ReitekIntegrationTechnology__c = 'Web Service'
            WITH SECURITY_ENFORCED
        ];
    }

    public static Campaign getCampaignId(String campaignName) {
        String query = 'SELECT Id FROM Campaign WHERE Name = :campaignName';
        List<Campaign> campaign = Database.query(query);

        return campaign[0];

    }

    public Campaign getSurveyCampaignById(String campaignId) {
        String query = 'SELECT Id, SurveyCRM__c FROM Campaign WHERE id = :campaignId';
        List<Campaign> campaign = Database.query(query);
        return campaign[0];
    }

    public List<Campaign> getCommercialCode(String commercialCode, String campaignId) {
        return [
            SELECT 
            Id,
            PrefixCode__c
            FROM Campaign
            where PrefixCode__c = :commercialCode
            AND Id != :campaignId
            WITH SECURITY_ENFORCED
        ];
    }

    public Campaign getCommercialCodeCampaign(String campaignId) {
        return [
            SELECT 
            Id,
            PrefixCode__c,
            MaxNumberEECodeUse__c,
            MaxNumberGASCodeUse__c,
            MaxNumberVASCodeUse__c
            FROM Campaign
            WHERE Id = :campaignId
            WITH SECURITY_ENFORCED
        ];
}
    public static List<Campaign> campaignByNameMacroActivityEasyCIM (String name){
        return [
            SELECT Id,Name,MacroActivityEasyCIM__c, MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c,AssignmentType__c,MacroActivityEasyCIM__r.Name,CreatedDate 
            FROM Campaign
            WHERE MacroActivityEasyCIM__r.Name = :name AND Category__c='Campagna Outbound' AND ReitekIntegrationTechnology__c ='Web Service' WITH SECURITY_ENFORCED
        ];
    }
    /**@frpanico 04/02/2022
     * Aggiunto metodo per
     * query tramite Tipology__c
     * in corso
     * e la piu recente
     */
    public static List<Campaign> getCampaingByTipology(String tipology, Set<String> orderAccountCompanyOwnersSet)
    {
        return [
            SELECT 
            Id,
            Name,
            MacroActivityEasyCIM__c,
            MacroActivityEasyCIM__r.idMacroActivityEasyCIM__c,
            AssignmentType__c,
            CompanyOwner__c
            FROM Campaign
            where Tipology__c = :tipology
            AND Status = 'In Corso'
            AND CompanyOwner__c IN: orderAccountCompanyOwnersSet
            WITH SECURITY_ENFORCED
            ORDER BY StartDate DESC
        ];
    }

    public static Map<String, Campaign> getCampaignByCompOwner(String tipology, Set<String> orderAccountCompanyOwnersSet){
        
        Map<String, Campaign> compOwnerToCampMap = new Map<String, Campaign>();
        
        for(Campaign camp : getCampaingByTipology(tipology, orderAccountCompanyOwnersSet)){
            if(compOwnerToCampMap.get(camp.CompanyOwner__c) == null){
                compOwnerToCampMap.put(camp.CompanyOwner__c, camp);
            }
        }
        return compOwnerToCampMap;
    }
}