/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 05/01/2020
* @description HDT_QR_Order – Contains queries for Order
* @history Keltin Mesonjesi – 05/01/2020 – Created class
*/
public inherited sharing class HDT_QR_Order {
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/01/2020
    * @description Get list of records by Sale__c.Id
    * @param saleId – Sale__c.Id
    * @return List<Order>
    */
    public List<Order> getRecordBySale(String saleId){
        return [
            SELECT
            Name,
            AccountId,
            Account.Name,
            Account.VATNumber__c,
            Account.FiscalCode__c,
            Status,
            ContractSigned__c,
            SignedDate__c,
            SignatureMethod__c,
            DocSendingMethod__c
            FROM Order 
            WHERE Sale__c = :saleId
            WITH SECURITY_ENFORCED
            ];
    }

    /**
    * @description Get orders records
    * @param orderId
    * @return Map<Id, Order> 
    */
    public Map<Id, Order>  getOrdersRecord(list <Id> orderId){
        Map<Id, Order> mapIdOrder=new  Map<Id, Order>([
            SELECT
            Name, AccountId,SAPImplantCode__c,SalesCompany__c,SapContractCode__c,EffectiveDate__c,ContractAccountCode__c,  Account.Name, Account.VATNumber__c, Account.FiscalCode__c,BillingProfile__c,ServicePoint__c,
            Status, ContractSigned__c, SignedDate__c, SignatureMethod__c, DocSendingMethod__c,Market__c,VAT__c, SBQQ__Quote__r.SBQQ__PriceBook__c,  
            CommercialProduct__c, TemporaryConnectionEndDate__c, ProcessType__c
            FROM Order 
            WHERE Id IN :orderId
            WITH SECURITY_ENFORCED
            ]);
       
        return mapIdOrder;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2020
    * @description Get list of records by Sale__c.Id and filtered by recordTypeId
    * @param saleId – Sale__c.Id
    * @param recordTypeId
    * @return List<Order>
    */
    public List<Order> getRecordBySaleFilterRecordTypeId(String saleId, String recordTypeId){
        return [
            SELECT
            Name,
            OrderNumber,
            RecordTypeId,
            AccountId,
            Account.Name,
            Account.FirstName__c,
            Account.LastName__c,
            Account.VATNumber__c,
            Account.FiscalCode__c,
            Account.BillingAddress,
            Account.ShippingAddress,
            Account.RecordType.DeveloperName,
            Status,
            ContractSigned__c,
            SignedDate__c,
            SignatureMethod__c,
            DocSendingMethod__c,
            CreatedDate,
            Step__c,
            Phase__c
            FROM Order 
            WHERE Sale__c = :saleId
            AND RecordTypeId = :recordTypeId
            WITH SECURITY_ENFORCED
            ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 07/01/2020
    * @description Get record by record Id
    * @param orderId
    * @return Order
    */
    public Order getRecordById(String orderId){
        return [
            SELECT 
            AccountId,
            Account.Name,
            Account.VATNumber__c,
            Account.FiscalCode__c,
            Account.BillingAddress,
            Account.ShippingAddress,
            Account.BirthProvince__c,
            Account.BirthDate__c,
            Account.FirstName__c,
            Account.LastName__c,
            Account.BillingPlace__c,
            Account.CompanyOwner__c,
            Account.RecordTypeName__c,
            Sale__r.SalesContact__c,
            Sale__r.Ecid__c,
            Sale__r.CreatedDate,
            Sale__r.SalesContact__r.FiscalCode__c,
            Sale__r.SalesContact__r.VATNumber__c,
            Username__c,
            SalesContact__r.Email,
            SalesContact__r.MobilePhone,
            SalesContact__r.VATNumber__c,
            SalesContact__r.FiscalCode__c,
            Sale__r.Channel__c,
            SwitchOutDate__c,
            Vat__c,
            ExciseGas__c,
            ExciseEle__c,
            Account.RecordType.Developername,
            Account.Category__c,
            Name,
            RecordTypeId,
            RecordType.Name,
            RecordType.DeveloperName,
            SystemModstamp,
            Status,
            ContractSigned__c,
            SignedDate__c,
            SignatureMethod__c,
            DocSendingMethod__c,
            Sale__c,
            CreatedDate,
            Step__c,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            //INIZIO SVILUPPI EVERIS
            ContractId,
            ServicePoint__r.CommoditySector__c,
            //FINE SVILUPPI EVERIS
            ServicePoint__r.RecordType.DeveloperName,
            ServicePoint__r.Account__c,
            ServicePoint__r.distributor__r.name,
            ServicePoint__r.distributor__c,
            ServicePoint__r.isReseller__c,
            ServicePoint__r.distributor__r.code__c,
            ServicePoint__r.MeterClass__c,
            ServicePoint__r.MeterStatus__c,
            ServicePoint__r.PlugPresence__c,
            ServicePoint__r.UseTypeEnergy__c,
            ServicePoint__r.UseCategory__c,
            ServicePoint__r.Vat__c,
            ServicePoint__r.ExciseEle__c,
            ServicePoint__r.ExciseGas__c,
            ServicePoint__r.SapContractStatus__c,
            PowerAvailable__c,
            UseTypeEnergy__c,
            BillingProfile__c,
            Deliberation__c,
            ParentOrder__c,
            ParentOrder__r.Status,
            ParentOrder__r.Phase__c,
            ParentOrder__r.ContractSigned__c,
            ParentOrder__r.SignedDate__c,
            OrderNumber,
            Phase__c, 
            RequestOption__c,
            WaiverRightAfterthought__c,
            MaxAfterthoughtDate__c,
            PreviousTrader__c,
            VolturaThirdTrader__c,
            SBQQ__Quote__r.IsVAS__c,
            SBQQ__Quote__r.IsBillableVas__c,
            SBQQ__Quote__r.AmendmentAllowed__c,
            SBQQ__Quote__r.ContractReference__c,
            SBQQ__Quote__r.OrderReference__c,
            SBQQ__Quote__r.ContractReference__r.ContractNumber,
            SBQQ__Quote__r.OrderReference__r.OrderNumber,
            SBQQ__Quote__r.AllowChangeUse__c,
            SBQQ__Quote__r.SBQQ__Type__c,
            ProcessType__c,
            SalesCompany__c,
            Campaign__c,
            Campaign__r.Name,
            ContractReference__c,
			RequestPhase__c,
			ConnectionType__c,
			ProcessCode__c,
            ContractReference__r.ServicePoint__c,
            ContractReference__r.ServicePoint__r.ServicePointCode__c,
            OrderReference__c,
            OrderReference__r.SBQQ__Quote__c,
            OrderReference__r.ServicePoint__r.ServicePointCode__c,
            OrderReference__r.ServicePoint__c,
            SBQQ__Quote__c,
            ContractReference__r.ContractNumber,
            OrderReference__r.OrderNumber,
            ActivationStreetName__c,
            ActivationCity__c,
            ActivationPostalCode__c,
            ActivationCountry__c,
            ActivationProvince__c,
            ActivationStreetNumberExtension__c,
            ActivationStreetNumber__c,
            ImplantType__c,
            PowerCommitted__c,
            PowerRequested__c,
            ServicePoint__r.MarketOrigin__c,                // @Picchiri 21/05/21
            WizardCompletedDate__c,                         // @Picchiri 21/05/21
            ActivatedDate,                                  // @Picchiri 21/05/21
            ServicePoint__r.VoltageLevel__c,                // @Picchiri 21/05/21
            ServicePoint__r.SupplyType__c,                  // @Picchiri 21/05/21
            ServicePoint__r.SupplyTypeTemp__c,
            RecessNotice__c,                                // @Picchiri 21/05/21
            CustomerCategory__c,                            // @Picchiri 26/05/21
            Channel__c,                                     // @Picchiri 27/05/21
            Market__c,                                      // @Picchiri 26/05/21
            MarketOrigin__c,                                // @Picchiri 27/05/21
            VoltageLevel__c,                                // @Picchiri 27/05/21 
            SupplyType__c,
            supplyTypeTechnical__c,                                  // @Picchiri 27/05/21 
            CreatedById,                                    // @Picchiri 31/05/21 
            Account.CustomerCode__c,                        // @Picchiri 31/05/21             
            Account.CustomerMarking__c,                     // @Picchiri 31/05/21             
            Account.CustomerType__c,                        // @Picchiri 31/05/21 
            ServicePoint__r.SupplyStreetName__c,            // @Picchiri 31/05/21  
		    ServicePoint__r.SupplyCity__c,                  // @Picchiri 31/05/21 
		    ServicePoint__r.SupplyProvince__c,              // @Picchiri 31/05/21 
		    ServicePoint__r.SupplyPostalCode__c,            // @Picchiri 31/05/21
            ServicePoint__r.Account__r.CustomerCode__c,     // @Picchiri 08/06/21             
            ServicePoint__r.Account__r.FiscalCode__c,       // @Picchiri 08/06/21             
            CommercialProduct__c,                           // @Picchiri 31/05/21 
            AnnualConsumption__c,                           // @Picchiri 31/05/21 
            Catalog__c,                                     // [ 07/06/2021 alessio.murru@webresults.it - credit check ]
            ServicePoint__r.AnnualConsumptionStandardM3__c, // [ 07/06/2021 alessio.murru@webresults.it - credit check ]
            BillingProfile__r.AccountClass__c,              // @Picchiri Calcolo della date Switch in 08/06/21             
            OwnerId,                                        // @Picchiri  10/06/21
            OrderReferenceNumber,                            // @Picchiri  15/06/21
            IsSequanzialized__c,                             // @Picchiri  24/06/21
            ServicePoint__r.AnnualConsumption__c,                            
            SalesCompanyCode__c,
            Owner.Username,
            CustomerType__c,
            IsWinback__c, 
            IsBillableVas__c,
            ChannelTransCode__c,
            IsActivationDeferred__c,
            EffectiveDate__c ,                              // [ 13/08/2021 gabriele.rota@webresults.it - Calcolo Data Invio al SII ]
            ConfirmCustomerContract__c,
            IsVAS__c,
            ServicePoint__r.Resident__c,                     // [ 26/08/2021 gabriele.rota@webresults.it - Calcolo IVA ]
            ServicePoint__r.AreaDeclaredTARI__c, 
            ServicePoint__r.Account__r.VATNumber__c,
            ServicePoint__r.Account__r.RecordType.DeveloperName,
            ServicePoint__r.Account__r.BirthDate__c, //17/05/2022 HRADTR_GV_Main
            Contact__c, //HRAWRM-418
            OutgoingCreditCheckResult__c,
            IncomingCreditCheckResult__c,
            DisconnectibilityPhone__c,          // 0110 LG Dati discordanti
            MaxRequiredPotential__c,           // 0110 LG Dati discordanti
            HerokuPracticeCode__c,             // 0110 LG Dati discordanti
            UseCategory__c,                   // 0110 LG Dati discordanti
            MeterSN__c,                     // 0110 LG Dati discordanti
            Resident__c,                    // 0110 LG Dati discordanti
            RemiCode__c,                    // 0110 LG Dati discordanti
            SupplyCity__c,                   // 0110 LG Dati discordanti
            SupplyStreetName__c,             // 0110 LG Dati discordanti
            SupplyStreetNumber__c,             // 0110 LG Dati discordanti
            SupplyStreetNumberExtension__c,     // 0110 LG Dati discordanti
            SupplyPlace__c,                      // 0110 LG Dati discordanti
            SupplyPostalCode__c,               // 0110 LG Dati discordanti
            SupplyCountry__c,                   // 0110 LG Dati discordanti
            SAPImplantCode__c,                 // 0110 LG Dati discordanti
            servicepointcode__c,
            ratecategory__c,
            SupplyCityCode__c,
            SupplyState__c,
            Disconnectable__c,
            DisconnectibilityType__c,
            InstanceSelfCertification__c,
            ConnectionMandate__c,
            SelfCertificationConnection__c,
            MeterClass__c,
            Caliber__c,
            PrecheckResultSII__c,
            WithdrawalClass__c,
            DistributorCode__c,
            PressureLevel__c,
            EnergyService__c,
            IsRemoteManaged__c,
            CustomerRequestDate__c,
            Commodity__c,
            LiftingPeople__c,
            MeterType__c,
            CreditCheckDescription__c,
            DocumentPackage__c,
            IsCloned__c,                                     // [ 02/08/2021 gabriele.rota@webresults.it - Package B Attivazioni ]
            RegionalAdditional__c,                            //@frpanico 16/09/21 
            isTransition__c,
            QuotationType__c,
            CommodityFormula__c,                              //@frpanico 28/09/21
            Email__c,                                          //@frpanico 28/09/21
            HerAteco__c,
            AtecoCode__c,
            PhoneNumber__c,
            CommentForDL__c,
            SubjectCode__c,
            InvoiceCertifiedEmailAddress__c,
            ElectronicInvoicingMethod__c,
            XMLType__c,
            CIG__c,
            CUP__c,
            IbanIsForeign__c,
            IbanABI__c,
            IbanCIN__c,
            IbanCIN_IBAN__c,
            IbanCAB__c,
            IbanCodeNumber__c,
            BankAccountSignatoryFiscalCode__c,
            BankAccountSignatoryFirstName__c,
            BankAccountSignatoryLastName__c,
            BillSendMode__c,
            PaymentMode__c,
            InvoiceEmailAddress__c,
            BillingCity__c,
            BillingCountry__c,
            BillingProvince__c,
            BillingStreetName__c,
            BillingStreetNumber__c,
            BillingStreetNumberExtension__c,
            BillingPostalCode__c,
            BillingCityCode__c,
            SignatoryType__c,
            SendCertifiedEmailConsentDate__c,
            CreateContractAccount__c,
            IbanCountry__c,
            CommercialProductVersion__c,
            CommercialProductCode__c,
            IsEarlyActivation__c,
            DistributorFormula__c,
            CreditCheckInProgress__c,
            Contact__r.FiscalCode__c,
            AggregateBilling__c,
            NumeratorGroup__c,
            VASSubtype__c,
            isSTG__c,
            Contact__r.Phone,
            Contact__r.MobilePhone,
            SubscriberType__c,
            Subprocess__c,
            LandRegistry__c,
            TaxpayerDeclarationInfos__c,
            AnnualTARIPayment__c,
            RequestSource__c,
            DeliveredDocumentation__c,
            ApprovalType__c,
            AdditionalAttachments__c,
            WasteCommodityType__c,
            VASType__c
            FROM Order 
            WHERE Id = :orderId
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description Get order by Id
    * @param id
    * @return Order
    */
    public Order getOrderbyId(String id){
        return [Select id,FriendCode__c from Order Where id = :id][0];
    }

    /**
    * @description getOrderByIdForSalesCallout
    * @param id
    * @return List<Order>
    */
    public List<Order> getOrderByIdForSalesCallout(String id){
        return [
            SELECT 
            Id,
            Phase__c,
            PrecheckResultSII__c,
            BillingProfile__c,
            ProcessType__c
            FROM Order 
            WHERE Id = :id
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 07/01/2020
    * @description Get records by IDs
    * @param orderIds - List<String>
    * @return List<Order>
    */
    public List<Order> getRecordsByIds(List<String> orderIds){
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE,
        [
            SELECT 
            AccountId,
            Account.Name,
            Account.VATNumber__c,
            Account.FiscalCode__c,
            Account.BillingAddress,
            Account.ShippingAddress,
            Account.FirstName__c,
            Account.LastName__c,
            Account.RecordType.Developername,
            Account.Category__c,
            DocumentalPhase__c,
            Name,
            RecordTypeId,
            RecordType.Name,
            RecordType.DeveloperName,
            SystemModstamp,
            Status,
            ContractSigned__c,
            ContractAccountCode__c,
            SignedDate__c,
            SignatureMethod__c,
            DocSendingMethod__c,
            Sale__c,
            TecnicalPhase__c,
            CreatedDate,
            Step__c,
            Sale__r.Channel__c,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            //INIZIO SVILUPPI EVERIS
            ContractId,
            ServicePoint__r.CommoditySector__c,
            //FINE SVILUPPI EVERIS
            ServicePoint__r.RecordType.DeveloperName,
            ServicePoint__r.Account__c,
            ServicePoint__r.MeterClass__c,
            ServicePoint__r.UseTypeEnergy__c,
            ServicePoint__r.UseCategory__c,
            BillingProfile__c,
            Deliberation__c,
            ParentOrder__c,
            ParentOrder__r.Status,
            ParentOrder__r.Phase__c,
            ParentOrder__r.ContractSigned__c,
            ParentOrder__r.SignedDate__c,
            OrderNumber,
            Phase__c, 
            RequestOption__c,
            WaiverRightAfterthought__c,
            MaxAfterthoughtDate__c,
            PreviousTrader__c,
            VolturaThirdTrader__c,
            SBQQ__Quote__r.IsVAS__c,
            SBQQ__Quote__r.AmendmentAllowed__c,
            SBQQ__Quote__r.ContractReference__c,
            SBQQ__Quote__r.OrderReference__c,
            SBQQ__Quote__r.ContractReference__r.ContractNumber,
            SBQQ__Quote__r.OrderReference__r.OrderNumber,
            SBQQ__Quote__r.AllowChangeUse__c,
            ProcessType__c,
            SalesCompany__c,
            Campaign__c,
            Campaign__r.Name,
            ContractReference__c,
            ContractReference__r.ServicePoint__c,
            OrderReference__c,
            ContractReference__r.ContractNumber,
            OrderReference__r.OrderNumber,
            ActivationStreetName__c,
            ActivationCity__c,
            ActivationPostalCode__c,
            ActivationCountry__c,
            ActivationProvince__c,
            ActivationStreetNumberExtension__c,
            ActivationStreetNumber__c,
            ImplantType__c,
            PowerCommitted__c,
            ServicePoint__r.MarketOrigin__c,                
            WizardCompletedDate__c,                         
            ActivatedDate,                                  
            ServicePoint__r.VoltageLevel__c,                
            ServicePoint__r.SupplyType__c, 
            ServicePoint__r.SupplyTypeTemp__c,                 
            RecessNotice__c,                                
            CustomerCategory__c,                            
            Channel__c,                                     
            Market__c,                                      
            MarketOrigin__c,                                
            VoltageLevel__c,                                 
            SupplyType__c,                                   
            CreatedById,                                     
            Account.CustomerCode__c,                                     
            Account.CustomerMarking__c,                                  
            Account.CustomerType__c,                         
            ServicePoint__r.SupplyStreetName__c,             
		    ServicePoint__r.SupplyCity__c,                   
		    ServicePoint__r.SupplyProvince__c,               
		    ServicePoint__r.SupplyPostalCode__c,            
            ServicePoint__r.Account__r.CustomerCode__c,                  
            ServicePoint__r.Account__r.FiscalCode__c,                    
            CommercialProduct__c, 
            HerokuPracticeCode__c, 
            sale__r.isTransition__c,                           
            AnnualConsumption__c,                            
            Catalog__c,                                     
            ServicePoint__r.AnnualConsumptionStandardM3__c, 
            ServicePoint__r.isSTG__c, 
            BillingProfile__r.AccountClass__c,                           
            OwnerId,                                        
            OrderReferenceNumber,
            SalesCompanyCode__c,
            IsSequanzialized__c,
            isTransition__c,
            CustomerType__c,
            IsWinback__c,
            AutorizationVolturaThirdTrader__c,
            CILegalRepresentative__c,
            CIAccoutn__c,
            QuickQuote__c,
            ChamberCommerceRegistration__c,
            DocumentPackage__c,
            Instance326__c,
            DocumentLow80__c,
            QualityCall__c,
            AgencyCode__c,
            DistributorFormula__c,
            VASType__c,
            ProcessCode__c,
            DistributorCode__c,
            Commodity__c,
            ComfortCallDaysDue__c,
            IsEarlyActivation__c,
            Contact__r.FiscalCode__c,
            Contact__c,
            IntegratedSAP__c,
            isSTG__c
            FROM Order 
            WHERE Id IN :orderIds
            WITH SECURITY_ENFORCED
        ]);

        return decision.getRecords();
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 07/01/2020
    * @description Get child records by parent order Id
    * @param parentOrderId - String
    * @return List<Order>
    */
    public List<Order> getChildOrdersByParentId(String parentOrderId){
        return [
            SELECT 
            AccountId,
            Account.Name,
            Account.Recordtype.DeveloperName,
            Name,
            Recordtypeid,
            Recordtype.Name,
            Recordtype.DeveloperName,
            Status,
            BillingProfile__c,
            BillingProfile__r.InvoicingCityCode__c,
            BillingProfile__r.InvoicingCountry__c,
            BillingProfile__r.InvoicingPlace__c,
            BillingProfile__r.InvoicingPostalCode__c,
            BillingProfile__r.InvoicingProvince__c,
            BillingProfile__r.InvoicingStreetName__c,
            BillingProfile__r.InvoicingStreetNumber__c,
            BillingProfile__r.InvoicingStreetNumberExtension__c,
            OrderNumber,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            Step__c,
            CILegalRepresentative__c,
            CIAccoutn__c,
            QuickQuote__c,
            ChamberCommerceRegistration__c,
            Instance326__c,
            DocumentLow80__c,
            AutorizationVolturaThirdTrader__c,
            VolturaThirdTrader__c,
            Phase__c,
            ComfortCallDaysDue__c,
            QualityCall__c,
            QualityCallUnique__c,
            Contact__r.Email,
            CreditCheckDescription__c,
            IncomingCreditCheckResult__c,
            OutgoingCreditCheckResult__c,
            OrderReference__c,
            OrderReference__r.Surface__c,
            ProcessType__c,
            SBQQ__Quote__c,
            CommercialProductCode__c,
            DocumentPackage__c,
            ApprovalType__c,
            IntegratedSAP__c,
            CommercialProduct__c,
            Type
            FROM
            Order
            WHERE ParentOrder__c = :parentOrderId
            AND Phase__c NOT IN ('Annullato')
            WITH SECURITY_ENFORCED
        ];
    }
    /**
    * @author NTTDATA
    * @date 16/02/2022
    * @description Get child records by list of parent Order Ids
    * @param parentOrderIds - List<String>
    * @return List<Order>
    */
    public List<Order> getChildOrdersForDateCalculation(List<String> parentOrderIds){
        return [
            SELECT
            Id,EffectiveDate__c,RecessNotice__c,WaiverRightAfterthought__c ,IsEarlyActivation__c ,ClientCategoryFormula__c,CommodityFormula__c,RecordType.DeveloperName,WizardCompletedDate__c,Account.RecordType.DeveloperName,Channel__c,Market__c,DocumentalProcessType__c,SignedDate__c,DateSentToSII__c,MaxAfterthoughtDate__c,IsActivationDeferred__c,ProcessType__c,MarketOrigin__c,ServicePoint__r.CommoditySector__c,VoltageLevel__c,SupplyType__c,CustomerCategory__c,SignatureMethod__c,DocSendingMethod__c,IsTransition__c
            FROM
            Order
            WHERE ParentOrder__c IN :parentOrderIds
            AND Phase__c NOT IN ('Annullato')
            AND CommodityFormula__c != 'Acqua'
            /* AND ProcessType__c != ''
            AND ProcessType__c != 'VAS' */
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 07/01/2020
    * @description Get child records by list of parent Order Ids
    * @param parentOrderIds - List<String>
    * @return List<Order>
    */
    public List<Order> getChildOrdersByParentIds(List<String> parentOrderIds){
        return [
            SELECT
            Phase__c,
            PhaseStory__c,
            isTransition__c ,
            recordtype.developername,
            AutorizationVolturaThirdTrader__c,
            CILegalRepresentative__c,
            CIAccoutn__c,
            sale__r.isTransition__c,
            AgencyCode__c,
            QualityCall__c,
            QuickQuote__c,
            ChamberCommerceRegistration__c,
            Instance326__c,
            DocumentLow80__c,
            DistributorFormula__c,
            VASType__c,
            ComfortCallDaysDue__c,
            DateComfortCall__c,
            DocumentPackage__c,
            ProcessType__c,
            ParentOrder__c,
            ParentOrder__r.Phase__c,
            IsEarlyActivation__c,
            DistributorCode__c,
            ApprovalType__c,
            IntegratedSAP__c,
            Commodity__c,
            ProcessCode__c
            FROM
            Order
            WHERE ParentOrder__c IN :parentOrderIds
            AND Phase__c NOT IN ('Annullato')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 20/02/2020
    * @description Get child records by parent order Id without status filtering
    * @param parentOrderId - String
    * @return List<Order>
    */
    public List<Order> getChildOrdersByParentIdAllStatus(String parentOrderId){
        return [
            SELECT 
            AccountId,
            Account.Name,
            Name,
            CommercialProduct__c,
            OfferType__c,
            Recordtypeid,
            Recordtype.Name,
            Recordtype.DeveloperName,
            Status,
            BillingProfile__c,
            BillingProfile__r.InvoicingCityCode__c,
            BillingProfile__r.InvoicingCountry__c,
            BillingProfile__r.InvoicingPlace__c,
            BillingProfile__r.InvoicingPostalCode__c,
            BillingProfile__r.InvoicingProvince__c,
            BillingProfile__r.InvoicingStreetName__c,
            BillingProfile__r.InvoicingStreetNumber__c,
            BillingProfile__r.InvoicingStreetNumberExtension__c,
            OrderNumber,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            Step__c,
            CILegalRepresentative__c,
            CIAccoutn__c,
            QuickQuote__c,
            ChamberCommerceRegistration__c,
            Instance326__c,
            DocumentLow80__c,
            AutorizationVolturaThirdTrader__c,
            Phase__c,
            SupplyAddressFormula__c,
            SBQQ__Quote__c
            FROM
            Order
            WHERE ParentOrder__c = :parentOrderId
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 11/01/2021
    * @description Get record by id and filter status
    * @param orderId - String
    * @param status - String
    * @return List<Order>
    */
    public List<Order> getRecordByIdFilterStatus(String orderId, String status){
        return [
            SELECT
            Status 
            FROM
            Order
            WHERE Id = :orderId
            AND Status = :status
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 27-09-2021 
    * @param quoteId 
    * @return List<Order> 
    **/
    public List<Order> getPodOrderFromQuote(String quoteId){
        return [
            SELECT
            ServicePoint__c 
            FROM
            Order
            WHERE
            SBQQ__Quote__c =:quoteId
            AND ServicePoint__c!=null
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get active records by accountId
    * @param accountId - String
    * @return List<Order>
    */
    public List<Order> getActiveRecordsByAccountId(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c
            FROM
            Order
            WHERE AccountId = :accountId
            AND ParentOrder__c = null
            AND Status = 'In Lavorazione'
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getRecordsByAccountId
    * @param accountId - String
    * @return List<Order>
    */
    public List<Order> getRecordsByAccountId(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c
            FROM
            Order
            WHERE AccountId = :accountId
            AND ParentOrder__c = null
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Order> getRecordsByAccountIdInPhases(String accountId, List<String> phases ){
        return [
            SELECT
            Id,
            Phase__c 
            FROM
            Order
            WHERE AccountId = :accountId
            AND Phase__c IN :phases
            WITH SECURITY_ENFORCED
        ];
    }

    
    public List<Order> getRecordsByAccountIdCopContrattoFirmato(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c,
            CreatedDate
            FROM
            Order
            WHERE AccountId = :accountId
            AND ParentOrder__c = null
            AND Status != 'Draft'
            AND Phase__c = 'Documentazione Gestita'
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Order> getRecordsByAccountIdCopContrattoNonFirmato(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c,
            CreatedDate
            FROM
            Order
            WHERE AccountId = :accountId
            AND ParentOrder__c = null
            AND Status != 'Draft'
            AND Phase__c != 'Documentazione Gestita'
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Order> getRecordsByAccountIdCopContrattoSignatureMethod(String accountId,String signatureMethod){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c
            FROM
            Order
            WHERE AccountId = :accountId
            AND ParentOrder__c = null
            AND Status != 'Draft'
            AND SignatureMethod__c = :signatureMethod
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getActiveRecordsByAccountIdNotParent
    * @param accountId - String
    * @return List<Order>
    */
    public List<Order> getActiveRecordsByAccountIdNotParent(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c
            FROM
            Order
            WHERE AccountId = :accountId
            AND RecordType.DeveloperName != 'HDT_RT_OrderDossier'
            AND Status IN ('In Lavorazione','Draft')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getRecordsForVasSelection
    * @param accountId - String
    * @return List<Order>
    */
    public List<Order> getRecordsForVasSelection(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            SalesCompany__c,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c,
            SBQQ__Quote__c,
            SBQQ__Quote__r.IsVAS__c,
            SBQQ__Quote__r.AmendmentAllowed__c,
            RecordTypeId,
            RecordType.DeveloperName,
            ProcessType__c,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            ServicePoint__r.SupplyAddress__c,
            ServicePoint__r.SupplyCity__c
            FROM
            Order
            WHERE AccountId = :accountId
            AND RecordType.DeveloperName != null
            AND RecordType.DeveloperName != 'HDT_RT_OrderDossier'
            AND SBQQ__Quote__r.IsVAS__c != true
            AND SBQQ__Quote__r.AmendmentAllowed__c != true
            AND Status IN ('In Lavorazione')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getRecordsNotActivated
    * @param accountId - String
    * @return List<Order>
    */
    public List<Order> getRecordsNotActivated(String accountId){
        return [
            SELECT
            Name,
            AccountId,
            OrderNumber,
            Status,
            SalesCompany__c,
            Agency__c,
            Market__c,
            Channel__c,
            FriendCode__c,
            CampaignCode__c,
            CreatedBy__c,
            SBQQ__Quote__c,
            SBQQ__Quote__r.IsVAS__c,
            SBQQ__Quote__r.AmendmentAllowed__c,
            RecordTypeId,
            RecordType.DeveloperName,
            ProcessType__c,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            ServicePoint__r.SupplyAddress__c
            FROM
            Order
            WHERE AccountId = :accountId
            AND RecordType.DeveloperName != null
            AND RecordType.DeveloperName != 'HDT_RT_OrderDossier'
            AND SBQQ__Quote__r.IsVAS__c != true
            AND SBQQ__Quote__r.AmendmentAllowed__c != true
            AND Status NOT IN ('Activated', 'Annullato')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getRecordByOrderNumber
    * @param orderNumber - String
    * @return List<Order>
    */
    /**@frpanico 26/10/2021
     * Added Supply Address Fields
     * Added Power Available/Committed
     * Added VoltageLevel
     */
    public List<Order> getRecordByOrderNumber(String orderNumber){
        return [SELECT id,
        phase__c,
        SupplyType__c,
        Description,
        PhaseStory__c,
        Status,
        PrecheckResultSII__c,
        ProcessType__c,
        BillingProfile__c, 
        Vat__c, 
        ServicePoint__c,
        ServicePoint__r.Distributor__r.Name,
        ServicePoint__r.Name,
        ServicePoint__r.ServicePointCode__c,
        CancellationNote__c,
        SupplyStreetName__c,
        SupplyStreetNumber__c,
        SupplyPostalCode__c,
        SupplyCityCode__c,
        SupplyCity__c,
        SupplyState__c,
        SupplyCountry__c,
        PowerCommitted__c,
        PowerAvailable__c,
        VoltageLevel__c,
        AccountId,
        IsTechnicalTransfer__c,
        Sale__c,
        Commodity__c,
        RecordTypeId,
        ParentOrder__c,
        ImplantType__c,
        CausalCode__c,
        QuotationNumber__c
        FROM Order 
        WHERE ordernumber = :orderNumber WITH SECURITY_ENFORCED];
    }
    public List<Order> getRecordByVasPracticeCode(String vasPracticeCode){
        return [SELECT id,
        phase__c,
        Description,
        PhaseStory__c,
        Status,
        PrecheckResultSII__c,
        ProcessType__c,
        BillingProfile__c, 
        Vat__c, 
        ServicePoint__c,
        ServicePoint__r.Distributor__r.Name, 
        CancellationNote__c,
        SupplyStreetName__c,
        SupplyStreetNumber__c,
        SupplyPostalCode__c,
        SupplyCityCode__c,
        SupplyCity__c,
        SupplyState__c,
        SupplyCountry__c,
        PowerCommitted__c,
        PowerAvailable__c,
        VoltageLevel__c,
        AccountId,
        IsTechnicalTransfer__c
        FROM Order 
        WHERE VasPracticeCode__c = :vasPracticeCode WITH SECURITY_ENFORCED];
    }
    /**@frpanico 26/10/2021
     * Added Supply Address Fields
     * Added Power Available/Committed
     * Added VoltageLevel
     */
    public List<Order> getOrdersByOrderNumber(List<String> orderNumbers){
        return [SELECT id,
        phase__c,
        Status,
        PrecheckResultSII__c,
        ProcessType__c,
        BillingProfile__c, 
        Vat__c, 
        ServicePoint__c,
        AccountId,
        CancellationNote__c,
        SupplyStreetName__c,
        SupplyStreetNumber__c,
        SupplyPostalCode__c,
        SupplyCityCode__c,
        SupplyCity__c,
        SupplyState__c,
        SupplyCountry__c,
        PowerCommitted__c,
        PowerAvailable__c,
        VoltageLevel__c,
        IsTechnicalTransfer__c,
        QuotationNumber__c
        FROM Order where Ordernumber IN :orderNumbers WITH SECURITY_ENFORCED];
    }

    /**
    * @description getRecordByOrderNumber
    * @param recordId - String
    * @return List<Order>
    */
    public List<Order> getRecordByOrderId(String recordId){
        return [SELECT id,
        phase__c,
        SupplyType__c,
        Description,
        PhaseStory__c,
        Status,
        PrecheckResultSII__c,
        ProcessType__c,
        BillingProfile__c, 
        Vat__c, 
        ServicePoint__c,
        ServicePoint__r.Distributor__r.Name,
        ServicePoint__r.Name,
        ServicePoint__r.ServicePointCode__c,
        CancellationNote__c,
        SupplyStreetName__c,
        SupplyStreetNumber__c,
        SupplyPostalCode__c,
        SupplyCityCode__c,
        SupplyCity__c,
        SupplyState__c,
        Commodity__c,
        SupplyCountry__c,
        PowerCommitted__c,
        PowerAvailable__c,
        VoltageLevel__c,
        AccountId,
        IsTechnicalTransfer__c,
        RecordTypeId,
        ParentOrder__c,
        ImplantType__c,
        CausalCode__c,QuotationNumber__c
        FROM Order 
        WHERE Id = :recordId WITH SECURITY_ENFORCED];
    }

    public List<Order> getRecordWithDocByOrderId(String recordId){
        return [SELECT id,
        phase__c,
        SupplyType__c,
        Description,
        PhaseStory__c,
        Status,
        PrecheckResultSII__c,
        ProcessType__c,
        BillingProfile__c, 
        Vat__c, 
        ServicePoint__c,
        ServicePoint__r.Distributor__r.Name,
        ServicePoint__r.Name,
        ServicePoint__r.ServicePointCode__c,
        CancellationNote__c,
        SupplyStreetName__c,
        SupplyStreetNumber__c,
        SupplyPostalCode__c,
        SupplyCityCode__c,
        SupplyCity__c,
        SupplyState__c,
        SupplyCountry__c,
        PowerCommitted__c,
        PowerAvailable__c,
        VoltageLevel__c,
        AccountId,
        IsTechnicalTransfer__c,
        RecordTypeId,
        ParentOrder__c,
        AutorizationVolturaThirdTrader__c,
        CILegalRepresentative__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        DocumentPackage__c
        FROM Order 
        WHERE Id = :recordId WITH SECURITY_ENFORCED];
    }

    /**
    * @description getRecordsByOrdersIdsBulk
    * @param orderIds - String
    * @return List<Order>
    */
    public List<Order> getRecordsByOrdersIdsBulk(List<String> orderIds){
        return [
            SELECT
            Id,
             BillingProfile__c,
             ServicePoint__c
             from Order
            WHERE Id IN :orderIds
            WITH SECURITY_ENFORCED
        ];
    }

    //INIZIO SVILUPPI EVERIS
    /**
    * @description getRoleNameByRoleId
    * @return String
    */
    public String getRoleNameByRoleId(){

        String userId = UserInfo.getUserId();

        return [SELECT UserRole.Name 
        FROM User 
        WHERE Id = :userId
        WITH SECURITY_ENFORCED
        LIMIT 1].UserRole.Name;
    }

    /**
    * @description getDates
    * @param recordId - String
    * @return Order
    */
    public Order getDates(String recordId){
        return [SELECT Id, EffectiveDate__c, RetroactiveDate__c,ServicePoint__c,BillingProfile__c
        FROM Order
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];
    }

    /**
    * @description getRecordsByIdWithFields
    * @param ids - List<String>
    * @param fields - String
    * @return List<Order>
    */
    public List<Order> getRecordsByIdWithFields(List<String> ids, String fields) {

        List<Order> orders = Database.query('SELECT '+ String.escapeSingleQuotes(fields) + ' From Order where Id IN :Ids');

        return orders;
    }
    
    //FINE SVILUPPI EVERIS
    /**
    * @description getOrderCreatedYesterday
    * @return List<Order>
    */
    public List<order> getOrderCreatedYesterday(){
        return [Select id,Account.Segment__c,LoginWorkstation__c,CreatorGroup__c,SalesCompany__c,account.SAPIntegrationID__c,account.RowIdSiebel__c,Account.Name,Account.Category__c,Account.CategoryCode__c,processType__c,OrderNumber,Recordtype.Name,Phase__c,CommodityFormula__c,OriginalOrderId,status, CreatedDate,Channel__c,Createdby.Name from Order where Createddate = Yesterday WITH SECURITY_ENFORCED];
    }

    public List<order> getOrderCreatedInRequestedDate(Datetime startDt, Datetime endDt){
        return [Select id,Account.Segment__c,LoginWorkstation__c,CreatorGroup__c,SalesCompany__c,account.SAPIntegrationID__c,account.RowIdSiebel__c,Account.Name,Account.Category__c,Account.CategoryCode__c,processType__c,OrderNumber,Recordtype.Name,Phase__c,CommodityFormula__c,OriginalOrderId,status, CreatedDate,Channel__c,Createdby.Name from Order where CreatedDate >=: startDt and CreatedDate <:endDt  WITH SECURITY_ENFORCED];
    }

    /**
    * @description getRecordTypesDeveloperNameById
    * @param id - List<String>
    * @return String
    */
    public static String getRecordTypesDeveloperNameById(Id id){
        String devName = [SELECT DeveloperName FROM RecordType WHERE id = :id].DeveloperName;
        return devName;
    }

    /**
    * @description getOrderForComfortQualityResult
    * @param parentOrderId - String
    * @return List<Order>
    */
    public List<order> getOrderForComfortQualityResult(String parentOrderId){
        return [SELECT 
            Id,
            AccountId,
            Account.Name,
            Recordtypeid,
            Recordtype.Name,
            Recordtype.DeveloperName,
            Status,
            Phase__c,
            OrderNumber,
            ProcessType__c,
            DateComfortCall__c,
            ComfortCallDaysDue__c,
            QualityCall__c,
            QualityCallUnique__c,
            ConfirmCustomerContract__c,
            CancellationReason__c,
            CommercialProduct__c,
            IsEarlyActivation__c,
            VasSubtype__c,
            VASType__c
        FROM Order
        WHERE ParentOrder__c = :parentOrderId
        AND QualityCall__c = true
        AND (VasSubtype__c != 'Analisi Consumi' OR ComfortCallDaysDue__c != NULL)
        AND Phase__c NOT IN ('Completata','Annullato')
        WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getOrderByUsernamePassword
    * @param username - String
    * @param password - String
    * @return List<Order>
    */
    public List<Order>  getOrderByUsernamePassword(String username, String password) {
        HDT_LC_CanaleIVRNoShare qrs = new HDT_LC_CanaleIVRNoShare();
        
        return qrS.getOrderByUsernamePassword(username,password);

    
    }
	
    /**
    * @description getChildOrdersDocumentalActivityByParentId
    * @param parentOrderId - String
    * @return List<Order>
    */
	public List<Order> getChildOrdersDocumentalActivityByParentId(String parentOrderId){
        return [
            SELECT 
            Id
           // DocumentalActivity__c,
           // DocumentalActivity__r.Name
            FROM
            Order
            WHERE ParentOrder__c = :parentOrderId
            AND Phase__c NOT IN ('Annullato')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getOrderForActiveMonitoringCheck
    * @param id - String
    * @return List<Order>
    */
    public List<Order> getOrderForActiveMonitoringCheck(String id){
        return [
            Select 
            id,
            Phase__c,
            AgencyCode__c, SignedDate__c
            from Order 
            Where id = :id
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @description getOrderForComfort
    * @param id - String
    * @return List<Order>
    */
    public List<Order> getOrderForComfort(String id){
        return [SELECT Id, Phase__c, SignedDate__c, isTransition__c, ProcessType__c, VASType__c, IsEarlyActivation__c, ComfortCallDaysDue__c, ParentOrder__c, RecordType.DeveloperName, DateComfortCall__c FROM Order WHERE Id = :id WITH SECURITY_ENFORCED];
    }

    public List<Order> getAllOrdersForComfort(String id){
        return [SELECT Id, Phase__c, ConfirmCustomerContract__c, CancellationReason__c, ParentOrder__c, QualityCall__c FROM Order WHERE QualityCall__c =true AND ParentOrder__c = :id WITH SECURITY_ENFORCED];
    }


    public List<Order> getOrdersList(List<String> ordIdList){
        return [SELECT Id, Phase__c, ProcessType__c, VASType__c, IsEarlyActivation__c, ComfortCallDaysDue__c, RecordType.DeveloperName FROM Order WHERE Id = :ordIdList WITH SECURITY_ENFORCED];
    }

    //@frpanico getExciseTranscode
    /**
    * @description getExciseTranscode
    * @param exciseString - String
    * @return HDT_ExciseTranscode__mdt
    */
    public HDT_ExciseTranscode__mdt getExciseTranscode(String exciseString)
    {
        return [SELECT Excise__c FROM HDT_ExciseTranscode__mdt WHERE Active__c = true AND ExciseString__c = :exciseString WITH SECURITY_ENFORCED LIMIT 1];
    }

    public List<Order> getParentOrderDocs(Order ord){
        return [Select id,DocumentPackage__c,CIAccoutn__c,AutorizationVolturaThirdTrader__c,CILegalRepresentative__c,QuickQuote__c,ChamberCommerceRegistration__c,Instance326__c,DocumentLow80__c from Order Where id = :ord.ParentOrder__c WITH SECURITY_ENFORCED];
    }
    public List<Order> getParentOrderDocs(List<String> ordParents){
        return [Select id,DocumentPackage__c,CIAccoutn__c,AutorizationVolturaThirdTrader__c,CILegalRepresentative__c,QuickQuote__c,ChamberCommerceRegistration__c,Instance326__c,DocumentLow80__c from Order Where id IN :ordParents WITH SECURITY_ENFORCED];
    }

    //@frpanico getOpenActivities
    public List<wrts_prcgvr__Activity__c> getOpenActivitiesByOrderId(String orderId)
    {
        return [SELECT Id, wrts_prcgvr__Status__c,Type__c FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c != 'Chiusa' AND wrts_prcgvr__IsClosed__c = false AND Order__c = :orderId WITH SECURITY_ENFORCED];
    }

    public static List<Order> getOrderQuality(Set<String> ordIdSet) {
        
        List<Order> ordList = new List<Order>();
        
        ordList = [SELECT Id, RecordType.DeveloperName, ParentOrder__c, ParentOrder__r.Id, ParentOrder__r.RecordType.DeveloperName FROM Order WHERE (Id = :ordIdSet OR ParentOrder__c = :ordIdSet) AND QualityCall__c = true WITH SECURITY_ENFORCED];

        return ordList;
    }

    public static Order getOrderWithLines(String orderId){
        if(String.isBlank(orderId))return null;
        return [SELECT Id,ServicePoint__c,BillingProfile__c,Market__c,PaymentMode__c,BillSendMode__c,VAT__c ,SapContractCode__c,Pricebook2Id,CommercialProduct__c, ProcessType__c,AccountId,EffectiveDate__c, EndDate,SignedDate__c,SalesCompany__c,RemiCode__c,Contact__c,(select Id,ProductFamily__c,Service__c, Product2Id,CompanyOwner__c,PaymentMode__c,Product2.Version__c,Surface__c, OccupantsNumber__c,SBQQ__RequiredBy__c from OrderItems) FROM Order WHERE Id=:orderId];
    }

    public static Map<String, List<String>> getOrdersByParent(Set<String> parentOrderSet){

        Map<String, List<String>> parToChildOrderMap = new Map<String, List<String>>();
        Set<String> ordPhase = new Set<String>{
            'In attesa conferma cliente',
            'Completata',
            'Annullato'
        };

        List<Order> orderList = [SELECT Id, OrderNumber, ParentOrder__c FROM Order WHERE ParentOrder__c IN :parentOrderSet AND QualityCall__c = true AND VasSubtype__c != 'Analisi Consumi' AND Phase__c NOT IN :ordPhase WITH SECURITY_ENFORCED];

        for(Order childOrd : orderList){
            if(parToChildOrderMap.get(childOrd.ParentOrder__c) != null){
                parToChildOrderMap.get(childOrd.ParentOrder__c).add(childOrd.OrderNumber);
            }
            else {
                parToChildOrderMap.put(childOrd.ParentOrder__c, new List<String>());
                parToChildOrderMap.get(childOrd.ParentOrder__c).add(childOrd.OrderNumber);
            }
        }
        return parToChildOrderMap;
    }
}