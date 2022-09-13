public inherited sharing class HDT_QR_Payments {

    public Case getCaseById(String recordId){

        return [SELECT Id,
        CaseNumber,
        TotalPaidCustomer__c,
        TotalPaidCustomerToPay__c,
        TotalToPay__c,
        TotalResidue__c,
        Deposit__c,
        DepositPaymentMode__c,
        InstallmentNumberRequired__c,
        ClientCategory__c,
        TypeInstallmentPlan__c,
        Reason__c,
        CAWithOrWithoutSEPA__c,
        ExistingInstallmentsPlanNumber__c,
        AmountToPayInInstallments__c,
        InstallmentAmount__c,
        DepositAmount__c,
        Amount__c,
        CutomerAssisted__c,
        RefundableEscape__c,
        WorkStatus__c,
        ApplicationInterests__c,
        SuspensionInThePastTwelveMonths__c,
        CreatedDate,
        ExpirationDate__c,
        AccountCode__c,
        PaymentDate__c,
        DocumentPaymentMethod__c,
        IbanABI__c,
        BeneficiaryAccount__r.Name,
        BillingProfile__r.ContractAccountCode__c,
        Type,
        CityOrInstitution__c,
        Note__c
        FROM Case
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        ];

    }


    public List<DocumentSelected__c> getDocumentSelectedByCase(String recordId){

        return[SELECT Id,
        Amount__c,
        DocumentResidue__c,
        DocumentNumber__c,
        ExpirationDate__c,
        Position1__c,
        Position2__c,
        Position3__c,
        Bill__c,
        TvFeeResidual__c,
        Type__c,
        PaidCustomer__c,
        Extension__c,
        IssueDate__c,
        TotalCommunicationPayment__c,
        Residue__c
        FROM DocumentSelected__c
        WHERE Case__c = :recordId
        WITH SECURITY_ENFORCED
        ];

      }


}
