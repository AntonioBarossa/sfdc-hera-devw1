/**
 * @author Lorenzo Gulotta (lorenzo.gulotta@webresults.it)
 * @date 24/06/2021
 * @description HDT_BA_RecurringCampaingCreation Class
 * @history Lorenzo Gulotta – 24/06/2021 – Created Class
 */
public with sharing class HDT_BA_RecurringCampaingCreation implements Database.Batchable<sObject>, Database.Stateful{
    
    public Date todayDate= Date.today();
    public List<Campaign> clonedCampaigns = new List<Campaign>();
    public List<Campaign> campaignToUpdate = new List<Campaign>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT IsDeleted, IsActive, RecurringCampaign__c, Required__c, ExpectedRevenue, BudgetedCost, ActualCost, AmountAllOpportunities, AmountWonOpportunities, HierarchyAmountAllOpportunities, HierarchyAmountWonOpportunities, HierarchyExpectedRevenue, HierarchyBudgetedCost, HierarchyActualCost, StartDate, EndDate, LastActivityDate, DateNextGeneration__c, CodeValidityEndDate__c, CreatedDate, LastModifiedDate, SystemModstamp, LastViewedDate, LastReferencedDate, NumberSent, HierarchyNumberSent, MaxNumberEECodeUse__c, MaxNumberGASCodeUse__c, MaxNumberVASCodeUse__c, GenerationPeriod__c, Priority__c, CodeConventionQuantity__c, Id, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, HierarchyNumberOfLeads, HierarchyNumberOfConvertedLeads, HierarchyNumberOfContacts, HierarchyNumberOfResponses, HierarchyNumberOfOpportunities, HierarchyNumberOfWonOpportunities, Channel__c, ExpectedResponse, CampaignMemberPercentageAllocation__c, Type, Status, CompanyOwner__c, Category__c, Segment__c, AssignmentType__c, BillTypeMessage__c, CodeGenerationRule__c, CodeManagementModel__c, ReitekIntegrationTechnology__c, TargetingMode__c, Tipology__c, ProcessType__c, CaseCategory__c, CaseSubCategory__c, ParentId, CampaignImageId, OwnerId, CreatedById, LastModifiedById, CampaignMemberRecordTypeId, CampaignEasyCIM__c, OriginalCampaign__c, MacroActivityEasyCIM__c, CampaignMemberAssigment__c, SurveyCRM__c, ScriptConfig__c, Name, PrefixCode__c, IdCampaignIBMUnica__c, Target__c, StaticTextMessageBill__c, Description, TargetDescription__c FROM Campaign WHERE Status != \'bozza\' AND RecurringCampaign__c=TRUE AND DateNextGeneration__c <= :todayDate and parentid = null AND enddate >: todayDate';
        System.debug(query);
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext bc, List<Campaign> scope){
        System.debug(scope);

        List<String> campaignIdTOQuery = new List<String>();
        Map<Id, Campaign> mapCampaign = new Map<Id, Campaign>();
        for(Campaign c: scope){
            System.debug(' c.GenerationPeriod__c'+ c.GenerationPeriod__c);
            Campaign campaign= c.clone(false,true,false,true);
            campaign.Status='Pianificata';
            String startDateMonth = c.StartDate.month() < 9 ? '0'+ String.valueOf(c.StartDate.month()) : String.valueOf(c.StartDate.month());
            String startDateDay = c.StartDate.day() < 9 ? '0'+ String.valueOf(c.StartDate.day()) : String.valueOf(c.StartDate.day());
            campaign.Name= c.Name +'_'+c.StartDate.year()+ startDateMonth + startDateDay;
            campaign.StartDate= todayDate.addDays(7);
            campaign.GenerationPeriod__c=c.GenerationPeriod__c!=null?c.GenerationPeriod__c:0.0;
            System.debug(' c.GenerationPeriod__c'+ campaign.GenerationPeriod__c);
           // campaign.enddate = campaign.StartDate.addDays(7 * (Integer.valueOf(campaign.GenerationPeriod__c)));
            if ( todayDate.addDays(7 *(Integer.valueOf( campaign.GenerationPeriod__c)))<campaign.enddate) {
                c.DateNextGeneration__c = todayDate.addDays(7 *(Integer.valueOf( campaign.GenerationPeriod__c)));
            }
            else {
                c.DateNextGeneration__c=null;
            }
            campaign.RecurringCampaign__c=false;
            campaign.OriginalCampaign__c=c.Id;
            campaignIdTOQuery.add(c.id);
            mapCampaign.put(c.id,c);
            clonedCampaigns.add(campaign);
            campaignToUpdate.add(c);
        }
        List<Campaign> campaignChildToQuery = HDT_QR_Campaign.getCampaignChild(campaignIdTOQuery);
        for(Campaign c : campaignChildToQuery){
         
            Campaign campaign= c.clone(false,true,false,true);
            campaign.Status='Pianificata';
            String startDateMonth = c.StartDate.month() < 9 ? '0'+ String.valueOf(c.StartDate.month()) : String.valueOf(c.StartDate.month());
            String startDateDay = c.StartDate.day() < 9 ? '0'+ String.valueOf(c.StartDate.day()) : String.valueOf(c.StartDate.day());
            campaign.Name= c.Name +'_'+todayDate.year()+ startDateMonth +startDateDay;
       
            campaign.IsActive=false;
            campaign.GenerationPeriod__c=null;
            System.debug(' 2 campaign.GenerationPeriod__c'+ campaign.GenerationPeriod__c);
            System.debug(' 2campaign.id'+ c.id);
            campaign.StartDate= todayDate.addDays(7);
            System.debug('StartDate : '+campaign.StartDate);
            System.debug('somma : '+7*(Integer.valueOf(mapCampaign.get(c.ParentId).GenerationPeriod__c!=null?mapCampaign.get(c.ParentId).GenerationPeriod__c:0.0)));
            
            campaign.enddate = campaign.StartDate.addDays(7*(Integer.valueOf(mapCampaign.get(c.ParentId).GenerationPeriod__c!=null?mapCampaign.get(c.ParentId).GenerationPeriod__c:0.0)));
            campaign.DateNextGeneration__c = null;
            campaign.RecurringCampaign__c=false;
            campaign.OriginalCampaign__c=c.Id;
            if ( campaign.enddate>mapCampaign.get(c.ParentId).endDate) {
                campaign.enddate=mapCampaign.get(c.ParentId).endDate;
            }
            if (mapCampaign.get(c.ParentId).endDate>campaign.StartDate) {
                clonedCampaigns.add(campaign);
            }
           
        }
        
    }
    public void finish(Database.BatchableContext bc){
        System.debug(clonedCampaigns);
        HDT_SRV_Campaign.insertCampaigns(clonedCampaigns);
        HDT_SRV_Campaign.updateCampaigns(campaignToUpdate);
    }
}