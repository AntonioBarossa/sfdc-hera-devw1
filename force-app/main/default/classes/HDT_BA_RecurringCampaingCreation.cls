public with sharing class HDT_BA_RecurringCampaingCreation implements Database.Batchable<sObject>, Database.Stateful{
    
    public Date todayDate= Date.today();
    public List<Campaign> clonedCampaigns = new List<Campaign>();
    public List<Campaign> campaignToUpdate = new List<Campaign>();
    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT IsDeleted, IsActive, RecurringCampaign__c, Required__c, ExpectedRevenue, BudgetedCost, ActualCost, AmountAllOpportunities, AmountWonOpportunities, HierarchyAmountAllOpportunities, HierarchyAmountWonOpportunities, HierarchyExpectedRevenue, HierarchyBudgetedCost, HierarchyActualCost, StartDate, EndDate, LastActivityDate, DateNextGeneration__c, CodeValidityEndDate__c, CreatedDate, LastModifiedDate, SystemModstamp, LastViewedDate, LastReferencedDate, NumberSent, HierarchyNumberSent, MaxNumberEECodeUse__c, MaxNumberGASCodeUse__c, MaxNumberVASCodeUse__c, GenerationPeriod__c, Priority__c, CodeConventionQuantity__c, Id, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, HierarchyNumberOfLeads, HierarchyNumberOfConvertedLeads, HierarchyNumberOfContacts, HierarchyNumberOfResponses, HierarchyNumberOfOpportunities, HierarchyNumberOfWonOpportunities, Channel__c, ExpectedResponse, CampaignMemberPercentageAllocation__c, Type, Status, CompanyOwner__c, Category__c, Segment__c, AssignmentType__c, BillTypeMessage__c, CodeGenerationRule__c, CodeManagementModel__c, ReitekIntegrationTechnology__c, TargetingMode__c, Tipology__c, ProcessType__c, CaseCategory__c, CaseSubCategory__c, ParentId, CampaignImageId, OwnerId, CreatedById, LastModifiedById, CampaignMemberRecordTypeId, CampaignEasyCIM__c, OriginalCampaign__c, MacroActivityEasyCIM__c, CampaignMemberAssigment__c, SurveyCRM__c, ScriptConfig__c, Name, PrefixCode__c, IdCampaignIBMUnica__c, Target__c, StaticTextMessageBill__c, Description, TargetDescription__c FROM Campaign WHERE Status != \'bozza\' AND RecurringCampaign__c=TRUE AND DateNextGeneration__c <= :todayDate and parentid == null AND enddate > TODAY';
        System.debug(query);
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext bc, List<Campaign> scope){
        System.debug(scope);
        List<String> campaignIdTOQuery = new List<String>();
        
        for(Campaign c: scope){
            Campaign campaign= c.clone(false,true,false,true);
            campaign.Status='Pianificata';
            campaign.Name= c.Name +'_'+c.StartDate.year()+ c.StartDate.month() + c.StartDate.day();
            campaign.StartDate= todayDate.addDays(7);
            campaign.enddate = campaign.StartDate.addDays(Integer.valueOf(7 * campaign.GenerationPeriod__c));
            c.DateNextGeneration__c = c.DateNextGeneration__c.addDays(Integer.valueOf(7 * campaign.GenerationPeriod__c));
            campaign.RecurringCampaign__c=false;
            campaign.OriginalCampaign__c=c.Id;
            campaignIdTOQuery.add(c.id);
            clonedCampaigns.add(campaign);
            campaignToUpdate.add(c);
        }
        List<Campaign> campaignChildToQuery = HDT_QR_Campaign.getCampaignChild(campaignIdTOQuery);
        for(Campaign c : campaignChildToQuery){
            Campaign campaign= c.clone(false,true,false,true);
            campaign.Status='Pianificata';
            campaign.Name= c.Name +'_'+todayDate.year()+ todayDate.month() + todayDate.day();
            campaign.StartDate= null;
            campaign.enddate = campaign.StartDate.addDays(Integer.valueOf(7 * campaign.GenerationPeriod__c));
            campaign.DateNextGeneration__c = null;
            campaign.RecurringCampaign__c=false;
            campaign.OriginalCampaign__c=c.Id;
            clonedCampaigns.add(campaign);
        }
        
    }
    public void finish(Database.BatchableContext bc){
        System.debug(clonedCampaigns);
        HDT_SRV_Campaign.insertCampaigns(clonedCampaigns);
        HDT_SRV_Campaign.updateSObject(c);
    }
}
    