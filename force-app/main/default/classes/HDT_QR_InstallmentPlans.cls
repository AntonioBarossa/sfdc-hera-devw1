public with sharing class HDT_QR_InstallmentPlans {
    public static RentProcessRule__c queryRules(Case c){

        RentProcessRule__c rule = new RentProcessRule__c();

        try{

            rule = [SELECT 	Id,MaxInstallmentsNumber__c,AttachmentManagement__c,ApprovalProcess__c,ClientCategory__c
            FROM RentProcessRule__c
            WHERE ClientCategory__c = :c.ClientCategory__c
            AND TypeInstallmentPlan__c = :c.TypeInstallmentPlan__c
            AND ApplicationInterests__c = :c.ApplicationInterests__c
            AND InstallmentPlanReason__c = :c.Reason__c
            AND CAWithOrWithoutSEPA__c = :c.CAWithOrWithoutSEPA__c
            AND (ExistingInstallmentPlanUnpaidFrom__c <= :decimal.valueof(c.ExistingInstallmentPlanUnpaid__c) OR ExistingInstallmentPlanUnpaidFrom__c = null)
            AND (ExistingInstallmentPlanUnpaidTo__c >= :decimal.valueof(c.ExistingInstallmentPlanUnpaid__c) OR ExistingInstallmentPlanUnpaidTo__c = null)
            AND (AmountToPayInInstallmentsFrom__c <= :c.AmountToPayInInstallments__c OR AmountToPayInInstallmentsFrom__c = null)
            AND (AmountToPayInInstallmentsTo__c >= :c.AmountToPayInInstallments__c OR AmountToPayInInstallmentsTo__c= null)
            AND SuspensionInPastTwelveMonths__c = :c.SuspensionInThePastTwelveMonths__c
            AND Deposit__c = :c.Deposit__c
            AND CustomerAssisted__c = :c.CutomerAssisted__c
            AND RefundableEscape__c = :c.RefundableEscape__c
            AND WorkStatus__c= :c.WorkStatus__c
            WITH SECURITY_ENFORCED
            LIMIT 1];

        } catch (Exception e){

            return rule;

        }

        return rule;
    }
}