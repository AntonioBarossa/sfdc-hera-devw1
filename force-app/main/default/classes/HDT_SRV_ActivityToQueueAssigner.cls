public with sharing class HDT_SRV_ActivityToQueueAssigner implements Queueable {
    private String activityId;

    HDT_SRV_ActivityToQueueAssigner(String activityId) {
        this.activityId = activityId;
    }
    
    public void execute(QueueableContext context) {
        wrts_prcgvr__Activity__c activity = [
            SELECT
                Id,
                Type__c,
                SAPStep__c,
                wrts_prcgvr__Priority__c,
                Account__r.CompanyOwner__c,
                Account__r.Category__c,
                Account__r.CustomerMarking__c,
                Account__r.CustomerCode__c,
                Account__r.Segment__c,
                Case__r.CriticalAttribute__c,
                Case__r.QuotationType__c,
                Case__r.CompetentOffice__c,
                Case__r.Origin,
                Case__r.FirstLevelOpinion__c,
                Case__r.SecondLevelOpinion__c,
                Case__r.DistributorName__c,
                Order__r.DistributorFormula__c,
                Case__r.Market__c,
                Order__r.Market__c,
                Case__r.SalesCompany__c,
                Order__r.SalesCompany__c,
                Case__r.Cluster__c,
                Order__r.Cluster__c,
                Case__r.ProcessType__c,
                Order__r.ProcessType__c,
                Case__r.SubProcess__c,
                Order__r.Subprocess__c,
                Case__r.Commodity__c,
                Order__r.CommodityFormula__c,
                Order__r.CreatedBy.UserCompany__c,
                Order__r.CreatedBy.CreatorGroup__c,
                Order__r.Channel__c,
                // Order__r.OfferType__c,
                Order__r.Sale__r.Channel__c
            FROM wrts_prcgvr__Activity__c
            WHERE
                Id =: activityId
        ];

        List<AssignmentRule__c> rule = [
            SELECT
                Id,
                HighPriorityQueue__c,
                MediumPriorityQueue__c,
                LowPriorityQueue__c
            FROM AssignmentRule__c
            WHERE
                RuleStartDate__c < TOMORROW AND RuleEndDate__c > TODAY AND
                Type__c =:activity.Type__c AND
                (SAPStep__c INCLUDES (:activity.SAPStep__c) OR SAPStep__c = null) AND
                (Priority__c INCLUDES (:activity.wrts_prcgvr__Priority__c) OR Priority__c = null) AND
                (CompanyOwner__c INCLUDES (:activity.Account__r.CompanyOwner__c) OR CompanyOwner__c = null) AND
                (ClientCategory__c INCLUDES (:activity.Account__r.Category__c) OR ClientCategory__c = null) AND
                (ClientMarking__c INCLUDES (:activity.Account__r.CustomerMarking__c) OR ClientMarking__c = null) AND
                (ComplaintSeverity__c INCLUDES (:activity.Case__r.CriticalAttribute__c) OR ComplaintSeverity__c = null) AND
                (QuoteType__c =: activity.Case__r.QuotationType__c OR QuoteType__c = null) AND
                (ArrearsOffice__c =: activity.Case__r.CompetentOffice__c OR ArrearsOffice__c = null) AND
                // (UserCreatorChannel__ INCLUDES (:activity.Case__r.Origin) OR UserCreatorChannel__ = null) AND
                (BPCode__c =: activity.Account__r.CustomerCode__c OR BPCode__c = null) AND
                (Segment__c INCLUDES (:activity.Account__r.Segment__c) OR Segment__c = null) AND
                // (FirstLevelOpinion__c INCLUDES (:activity.Case__r.FirstLevelOpinion__c) OR FirstLevelOpinion__c = null) AND
                // (SecondLevelOpinion__c INCLUDES (:activity.Case__r.SecondLevelOpinion__c) OR SecondLevelOpinion__c = null) AND
                // (UserCreatorAgency__c INCLUDES (:activity.Order__r.CreatedBy.UserCompany__c) OR UserCreatorAgency__c = null) AND
                // (UserCreatorGroup__c INCLUDES (:activity.Order__r.CreatedBy.CreatorGroup__c) OR UserCreatorGroup__c = null) AND
                (SalesChannel__c =: activity.Order__r.Channel__c OR SalesChannel__c = null) AND
                // (OfferType__c INCLUDES (:activity.Order__r.OfferType__c) OR OfferType__c = null) AND
                (Distributor__c =: activity.Case__r.DistributorName__c OR Distributor__c = null) AND
                (Distributor__c =: activity.Order__r.DistributorFormula__c OR Distributor__c = null) AND
                (Market__c INCLUDES (:activity.Case__r.Market__c) OR Market__c = null) AND
                (Market__c INCLUDES (:activity.Order__r.Market__c) OR Market__c = null) AND
                (Vendor__c =: activity.Case__r.SalesCompany__c OR Vendor__c = null) AND
                (Vendor__c =: activity.Order__r.SalesCompany__c OR Vendor__c = null) AND
                (MacroProcess__c INCLUDES (:activity.Case__r.Cluster__c) OR MacroProcess__c = null) AND
                (MacroProcess__c INCLUDES (:activity.Order__r.Cluster__c) OR MacroProcess__c = null) AND
                (Process__c INCLUDES (:activity.Case__r.ProcessType__c) OR Process__c = null) AND
                (Process__c INCLUDES (:activity.Order__r.ProcessType__c) OR Process__c = null) AND
                (SubProcess__c INCLUDES (:activity.Case__r.SubProcess__c) OR SubProcess__c = null) AND
                (SubProcess__c INCLUDES (:activity.Order__r.Subprocess__c) OR SubProcess__c = null) AND
                (Commodity__c INCLUDES (:activity.Case__r.Commodity__c) OR Commodity__c = null) AND
                (Commodity__c INCLUDES (:activity.Order__r.CommodityFormula__c) OR Commodity__c = null)
            ORDER BY
                RulePriority__c ASC
            LIMIT 1
        ];

        if(!rule.isEmpty()) {
            wrts_prcgvr__Activity__c a = new wrts_prcgvr__Activity__c(
                Id = activity.Id,
                Queued__c = true,
                AssignmentRule__c = rule[0].Id
            );

            switch on String.valueOf(activity.wrts_prcgvr__Priority__c) {
                when '1' {
                    a.OwnerId = rule[0].HighPriorityQueue__c;
                }
                when '2' {
                    a.OwnerId = rule[0].MediumPriorityQueue__c;
                }
                when '3' {
                    a.OwnerId = rule[0].LowPriorityQueue__c;
                }
            }
            update a;
        }
    }
}