public with sharing class HDT_QR_InstallmentPlans {
    public static RentProcessRule__c queryRules(Case c){

        RentProcessRule__c rule = new RentProcessRule__c();

        try{

            rule = [SELECT 	Id,MaxInstallmentsNumber__c,AttachmentManagement__c,ApprovalProcess__c,ClientCategory__c
            FROM RentProcessRule__c
            WHERE Category__c = :c.ClientCategory__c
            AND TypeInstallmentPlan__c = :c.TypeInstallmentPlan__c
            AND ApplicationInterests__c = :c.ApplicationInterests__c
            AND InstallmentPlanReason__c = :c.Reason__c
            AND CAWithOrWithoutSEPA__c = :c.CAWithOrWithoutSEPA__c
            AND (ExistingInstallmentPlanUnpaidFrom__c <= :c.ExistingInstallmentsPlanNumber__c OR ExistingInstallmentPlanUnpaidFrom__c = null)
            AND (ExistingInstallmentPlanUnpaidTo__c >= :c.ExistingInstallmentsPlanNumber__c OR ExistingInstallmentPlanUnpaidTo__c = null)
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

    public Case getCaseById(String recordId){

        return [SELECT 
        CaseNumber,
        DepositPaymentMode__c,
        InstallmentPlanNumber__c,
        ClientCategory__c,
        TypeInstallmentPlan__c,
        Reason__c,
        CAWithOrWithoutSEPA__c,
        ExistingInstallmentsPlanNumber__c,
        AmountToPayInInstallments__c,
        Deposit__c,
        Amount__c,
        CutomerAssisted__c,
        RefundableEscape__c,
        WorkStatus__c,
        ApplicationInterests__c,
        SuspensionInThePastTwelveMonths__c,
        CreatedDate,
        FirstExpirationDate__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }

    public List<DocumentSelected__c> getDocumentSelectedByCase(String recordId){

        return [SELECT Id,
        Bill__c,
        DocumentNumber__c,
        ExpirationDate__c,
        Type__c
        FROM DocumentSelected__c
        WHERE Case__c = :recordId
        WITH SECURITY_ENFORCED];

    }


    public List<Case> getSuspensionCaseByAccountId(String accountId){

        List<Case> cases = new List<Case>();

        DateTime pastTwelveMonth = (DateTime) System.today().addMonths(-12); 

        try{

            cases = [SELECT Id
            FROM Case
            WHERE Type = 'Sospesione Fornitura'
            AND Phase__c = 'Completata'
            AND CreatedDate >= :pastTwelveMonth
            AND AccountId = :accountId
            WITH SECURITY_ENFORCED
            LIMIT 1];

        } catch(Exception e){

            System.debug('QR_InstallmentPlans Exception--> ' + e.getMessage());
            
        }

        return cases;


    }
}