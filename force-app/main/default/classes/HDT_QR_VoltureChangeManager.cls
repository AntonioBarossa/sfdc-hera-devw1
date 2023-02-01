public with sharing class HDT_QR_VoltureChangeManager {
    
    /**
     * @frpanico 07/10/2021
     * Query Class for the VoltureChangeManager package
     */

    /*Retrieve all fields from OrderItem except system fields */
    public List<OrderItem> getOrderItemByOrderId(String orderId)
    {
        SObjectAccessDecision securityDecision = 
        Security.stripInaccessible(AccessType.READABLE,
        [SELECT Id, 
        Product2Id, 
        IsDeleted, 
        PricebookEntryId, 
        OriginalOrderItemId, 
        QuoteLineItemId, 
        AvailableQuantity, 
        Quantity, 
        UnitPrice, 
        ListPrice, 
        TotalPrice, 
        ServiceDate, 
        EndDate, 
        Description, 
        SBQQ__Activated__c, 
        SBQQ__Asset__c, 
        SBQQ__BillingFrequency__c, 
        SBQQ__BillingType__c, 
        SBQQ__BlockPrice__c, 
        SBQQ__BookingsIndicator__c, 
        SBQQ__BundleRoot__c, 
        SBQQ__ChargeType__c, 
        SBQQ__ContractAction__c, 
        SBQQ__Contract__c, 
        SBQQ__Contracted__c, 
        SBQQ__ContractingMethod__c, 
        SBQQ__DefaultSubscriptionTerm__c, 
        SBQQ__DimensionType__c, 
        SBQQ__DiscountSchedule__c, 
        SBQQ__OrderProductBookings__c, 
        //SBQQ__OrderedQuantity__c, 
        SBQQ__PriceDimension__c, 
        SBQQ__PriceSchedule__c, 
        SBQQ__PricingMethod__c, 
        SBQQ__ProductSubscriptionType__c, 
        SBQQ__ProrateMultiplier__c, 
        SBQQ__QuoteLine__c, 
        SBQQ__QuotedListPrice__c, 
        //SBQQ__QuotedQuantity__c, 
        SBQQ__RequiredBy__c, 
        SBQQ__RevisedOrderProduct__c, 
        SBQQ__SegmentIndex__c, 
        SBQQ__SegmentKey__c, 
        SBQQ__ShippingAccount__c, 
        SBQQ__Status__c, 
        SBQQ__SubscriptionPricing__c, 
        SBQQ__SubscriptionTerm__c, 
        SBQQ__SubscriptionType__c, 
        SBQQ__Subscription__c, 
        SBQQ__TaxAmount__c, 
        SBQQ__TaxCode__c, 
        SBQQ__TermDiscountSchedule__c, 
        SBQQ__TerminatedDate__c, 
        SBQQ__UnproratedNetPrice__c, 
        SBQQ__UpgradedSubscription__c, 
        DescriptionSAPBonusContributo__c, 
        BillingMode__c, 
        BillingProfile__c, 
        CategoryFamily__c, 
        Activity__c,
        ProductFamily__c, 
        ProductName__c, 
        CompanyOwner__c, 
        ConsumptionAnnualVAS__c,
        ConsumptionAnnual__c, 
        ProductVersion__c, 
        ContinuityChangeOffer__c,
        Convention__c, 
        CorrHCNonSchedule__c, 
        CorrHCSchedule__c, 
        DelayEffectiveDate__c, 
        DiscountEurMWh__c, 
        //Discount__c, 
        DurationVas__c, 
        DwellingType__c, 
        EmailRecipientVAS__c,
        GreenCertificateIncluded__c, 
        GreenEnergyOption__c, 
        GreenGasOption__c, 
        Index0PUN__c, 
        Index1PUN__c, 
        Index2PUN__c, 
        Index3PUN__c, 
        MaximumKITNumber__c, 
        MaximumPieceNumber__c, 
        MinimumPieceNumber__c, 
        SuperUser__c, 
        OccupantsNumber__c, 
        Origin__c, 
        OwnerAC__c, 
        PDRCode__c, 
        PODCode__c, 
        PaymentMode__c, 
        PhoneRecipient__c, 
        PreviousDateSwitch__c, 
        PriceFedFixed__c, 
        PriceFromThirds__c, 
        PriceGreenOption__c, 
        PriceNetDiscounted__c, 
        PriceNet__c, 
        PriceRidFixed__c, 
        QuoteIDCustom__c, 
        QuoteLine__c, 
        Quote__c, 
        Range__c, 
        Reading__c, 
        RegistrationNumber__c, 
        ReturnSafeGuardData__c, 
        SendingBillMode__c, 
        ServicePoint__c, 
        Service__c, 
        ShowInBill__c, 
        SignDate__c, 
        SupplyCity__c, 
        SupplyProvince__c, 
        SupplyZipCode__c, 
        Surface__c, 
        Typology__c, 
        VASBillingMode__c, 
        VasActivationDate__c, 
        //VasDuration__c, 
        WaitingPeriod__c, 
        PercentageF0__c, 
        PercentageF1__c, 
        PercentageF2__c, 
        PercentageF3__c, 
        PercentagePickOut__c, 
        PercentagePick__c, 
        Agency__c, 
        CampaignName__c, 
        Channel__c, 
        ClientAge__c, 
        ConsumptionRangeEE__c, 
        CustomerMarking__c, 
        DelayDayGas__c, 
        DelayDay__c, 
        DurationDayGas__c, 
        DurationDay__c, 
        IVA__c, 
        LoginGroup__c, 
        Login__c, 
        MeterType__c, 
        Percentage__c, 
        PriceGas__c, 
        Profile__c, 
        Role__c, 
        UseCategory__c, 
        PowerFlow__c, 
        Price__c, 
        KeepConsumptionsAnalysis__c, 
        TextInPrint__c, 
        Version__c, 
        CategoryTypeClient__c, 
        ConsumptionRangeGAS__c, 
        NewClient__c, 
        ResidentDeliveryAddress__c 
        FROM OrderItem 
        WHERE OrderId = : orderId]);

        return securityDecision.getRecords();
    }
    
    /* Get Order's Account Info */
    public List<Account> getAccountInfoById(String accountId)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE, 
            [SELECT RecordType.DeveloperName, CustomerMarking__c, Category__c FROM Account WHERE Id = :accountId]
            );

        return securityDecision.getRecords();
    }
    
    /* Get Acitivty Template */
    public List<wrts_prcgvr__ActivityTemplate__c> getActivityTemplateByName(String templateName)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE, 
            [SELECT id,
            wrts_prcgvr__Assignees__c, 
            wrts_prcgvr__Subject__c, 
            wrts_prcgvr__DueDateField__c,Name 
            FROM wrts_prcgvr__ActivityTemplate__c  
            WHERE Name = :templateName]);

        return securityDecision.getRecords();
    }

    /* Get Excise Rate */
    public List<HDT_ExciseTranscode__mdt> getExciseTranscode(String exciseString)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE, 
            [SELECT Excise__c 
            FROM HDT_ExciseTranscode__mdt 
            WHERE Active__c = true 
            AND ExciseString__c = :exciseString 
            ]);
        if(securityDecision.getRecords().isEmpty())
        {
            HDT_ExciseTranscode__mdt defaultMdt = new HDT_ExciseTranscode__mdt();
            defaultMdt.Excise__c = 0.0;
            return new List<HDT_ExciseTranscode__mdt>{defaultMdt};
        }
        return securityDecision.getRecords();
    }

    /* Get Account Infos */
    public List<AccountContactRelation> getContactInfosByAccountId(String accountId)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE,
            [SELECT ContactId
            FROM AccountContactRelation
            WHERE Roles = 'Titolare'
            AND AccountId = :accountId]);
        
        return securityDecision.getRecords(); 
    }

    /* Get Order Infos */
    public List<Order> getOrderInfosById(String orderId)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE,
            [SELECT PreviousCustomer__r.Account.CustomerMarking__c,
            NotRegisteredMeterCase__c,
            VoltureType__c,
            EffectiveDate__c,
            RetroactiveDate__c,
            Subprocess__c,
            PreviousCustomer__r.Account.RecordType.DeveloperName,
            Account.CustomerMarking__c,
            Account.RecordType.DeveloperName,
            ServicePoint__r.CommoditySector__c,
            RecordType.DeveloperName,
            NumeratorGroup__c,
            VASSubtype__c,
            Phase__c,
            IsTechnicalTransfer__c,
            PreviousHoldeCompanyName__c,
	        PreviousHolderFirstName__c,
	        PreviousHolderFiscalCode__c,
	        PreviousHolderLastName__c,
	        PreviousHolderVatNumber__c
            FROM Order
            WHERE Id = :orderId]);
    
        return securityDecision.getRecords();
    }

    /* Get Generic Data Enrichment Configs */
    public List<HDT_GenericDataEnrichmentTranscode__mdt> getDataEnrichmentTranscodeByObjectName(List<String> objectNameList)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE, 
            [SELECT SapField__c,
            SfdcField__c,
            Method__c,
            IsNumber__c,
            Precision__c,
            Commodity__c,
            CommodityField__c,
            ObjectName__c
            FROM HDT_GenericDataEnrichmentTranscode__mdt
            WHERE ObjectName__c IN :objectNameList]);

        return securityDecision.getRecords();
    }

}