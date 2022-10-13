public with sharing class HDT_QR_InstallmentPlans {
    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static List<RentProcessRule__c> queryRules(Case c){

        List<RentProcessRule__c> ruleList = new List<RentProcessRule__c>();

        try{
            ruleList = [SELECT Id,
            MaxInstallmentsNumber__c,
            AttachmentManagement__c,
            ApprovalProcess__c,
            Category__c,
            ApplicationInterests__c,
            CAWithOrWithoutSEPA__c,
            SuspensionInPastTwelveMonths__c,
            Deposit__c,
            RefundableEscape__c,
            WorkStatus__c,
            City__c,
            RateCategory__c
            FROM RentProcessRule__c
            WHERE Category__c = :c.ClientCategory__c
            AND InstallmentPlanReason__c = :c.Reason__c
            AND TypeInstallmentPlan__c =: c.TypeInstallmentPlan__c
            AND (ExistingInstallmentPlanUnpaidFrom__c <= :c.ExistingInstallmentsPlanNumber__c OR ExistingInstallmentPlanUnpaidFrom__c = null)
            AND (ExistingInstallmentPlanUnpaidTo__c >= :c.ExistingInstallmentsPlanNumber__c OR ExistingInstallmentPlanUnpaidTo__c = null)
            AND (AmountToPayInInstallmentsFrom__c <= :c.AmountToPayInInstallments__c OR AmountToPayInInstallmentsFrom__c = null)
            AND (AmountToPayInInstallmentsTo__c >= :c.AmountToPayInInstallments__c OR AmountToPayInInstallmentsTo__c= null) 
            WITH SECURITY_ENFORCED];
        } catch(Exception e){
            System.debug(LoggingLevel.DEBUG, 'QR_InstallmentPlans exception -> ' + e.getMessage());
        }

        return ruleList;

        /*RentProcessRule__c rule = new RentProcessRule__c();

        try{

            rule = [SELECT 	Id,MaxInstallmentsNumber__c,AttachmentManagement__c,ApprovalProcess__c,Category__c
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
            AND RefundableEscape__c = :c.RefundableEscape__c
            AND WorkStatus__c= :c.WorkStatus__c
            WITH SECURITY_ENFORCED
            LIMIT 1];

        } catch (Exception e){

            return rule;

        }

        return rule;*/
    }

    public Case getCaseById(String recordId){

        return [SELECT 
        CaseNumber,
        DepositPaymentMode__c,
        InstallmentNumberRequired__c,
        ClientCategory__c,
        TypeInstallmentPlan__c,
        Reason__c,
        CAWithOrWithoutSEPA__c,
        ExistingInstallmentsPlanNumber__c,
        AmountToPayInInstallments__c,
        InstallmentAmount__c,
        Deposit__c,
        DepositAmount__c,
        Amount__c,
        TotalPaidCustomer__c,
        CutomerAssisted__c,
        RefundableEscape__c,
        TotalToPay__c,
        TotalResidue__c,
        WorkStatus__c,
        ApplicationInterests__c,
        SuspensionInThePastTwelveMonths__c,
        CreatedDate,
        ExpirationDate__c,
        BillingCity__c,
        RateCategory__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }

    public List<DocumentSelected__c> getDocumentSelectedByCase(String recordId){

        return [SELECT Id,
        Bill__c,
        Amount__c,
        DocumentNumber__c,
        TvFeeResidual__c,
        ExpirationDate__c,
        Type__c
        FROM DocumentSelected__c
        WHERE Case__c = :recordId
        WITH SECURITY_ENFORCED];

    }

    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public List<Case> getSuspensionCaseByAccountId(String accountId){

        List<Case> cases = new List<Case>();

        DateTime pastTwelveMonth = (DateTime) System.today().addMonths(-12); 

        try{

            cases = [SELECT Id
            FROM Case
            WHERE Type = 'Sospensione Fornitura'
            AND Phase__c = 'Completata'
            AND CreatedDate >= :pastTwelveMonth
            AND AccountId = :accountId
            WITH SECURITY_ENFORCED
            LIMIT 1];

        } catch(Exception e){

            System.debug(LoggingLevel.DEBUG, 'QR_InstallmentPlans Exception--> ' + e.getMessage());
            
        }

        return cases;


    }

    /*
    * @Author: Salvatore A. Sarà 21/10/2021
    * Risoluzione "Debug Should Use Logging Level"
    * Risoluzione "Avoid debug statements since they impact on performance"
    */
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public String getPaymentMethodByCaseId(String recordId){

        String paymentMethod;

        try{

            paymentMethod = [SELECT 
            BillingProfile__r.PaymentMethod__c 
            FROM Case 
            WHERE Id = :recordId 
            WITH SECURITY_ENFORCED 
            LIMIT 1].BillingProfile__r.PaymentMethod__c ;

        } catch(Exception e){

            System.debug(LoggingLevel.DEBUG, 'QR_InstallmentPlans Exception--> ' + e.getMessage());
        
        }

        return paymentMethod;

    }

    public String getCustomerAssistedKpi(String accountId){

        return [SELECT AssistedCustomer__c 
        FROM Account 
        WHERE Id = :accountId 
        WITH SECURITY_ENFORCED 
        LIMIT 1].AssistedCustomer__c;

    }
}