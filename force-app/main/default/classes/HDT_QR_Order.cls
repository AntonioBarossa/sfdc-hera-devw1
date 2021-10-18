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
    * @param String saleId – Sale__c.Id
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
    public Map<Id, Order>  getOrdersRecord(list <Id> orderId){
        Map<Id, Order> mapIdOrder=new  Map<Id, Order>([
            SELECT
            Name, AccountId,  Account.Name, Account.VATNumber__c, Account.FiscalCode__c,BillingProfile__c,ServicePoint__c,
            Status, ContractSigned__c, SignedDate__c, SignatureMethod__c, DocSendingMethod__c,Market__c,VAT__c, SBQQ__Quote__r.SBQQ__PriceBook__c,  
            CommercialProduct__c  
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
    * @param String saleId – Sale__c.Id
    * @param String recordTypeId
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
    * @param String orderId
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
            Account.FirstName__c,
            Account.LastName__c,
            Account.CompanyOwner__c,
            Sale__r.SalesContact__c,
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
			RequestPhase__c,
			ConnectionType__c,
			ProcessCode__c,
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
            PowerRequested__c,
            ServicePoint__r.MarketOrigin__c,                // @Picchiri 21/05/21
            WizardCompletedDate__c,                         // @Picchiri 21/05/21
            ActivatedDate,                                  // @Picchiri 21/05/21
            ServicePoint__r.VoltageLevel__c,                // @Picchiri 21/05/21
            ServicePoint__r.SupplyType__c,                  // @Picchiri 21/05/21
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
            ServicePoint__r.Account__r.VATNumber__c,
            ServicePoint__r.Account__r.RecordType.DeveloperName,
            Contact__c, //HRAWRM-418
            OutgoingCreditCheckResult__c,
            IncomingCreditCheckResult__c,
            CreditCheckDescription__c
            FROM Order 
            WHERE Id = :orderId
            WITH SECURITY_ENFORCED
        ];
    }

    public Order getOrderbyId(String id){
        return [Select id,FriendCode__c from Order Where id = :id][0];
    }
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
    * @param List<String> orderIds
    * @return List<Order>
    */
    public List<Order> getRecordsByIds(List<String> orderIds){
        return [
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
            Instance326__c,
            DocumentLow80__c,
            QualityCall__c,
            AgencyCode__c
            FROM Order 
            WHERE Id IN :orderIds
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 07/01/2020
    * @description Get child records by parent order Id
    * @param String parentOrderId
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
            QualityCallUnique__c
            FROM
            Order
            WHERE ParentOrder__c = :parentOrderId
            AND Phase__c NOT IN ('Annullato')
            WITH SECURITY_ENFORCED
        ];
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 07/01/2020
    * @description Get child records by list of parent Order Ids
    * @param String parentOrderId
    * @return List<Order>
    */
    public List<Order> getChildOrdersByParentIds(List<String> parentOrderIds){
        return [
            SELECT
            Phase__c,
            isTransition__c ,
            recordtype.developername,
            AutorizationVolturaThirdTrader__c,
            CILegalRepresentative__c,
            CIAccoutn__c,
            QuickQuote__c,
            ChamberCommerceRegistration__c,
            Instance326__c,
            DocumentLow80__c
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
    * @param String parentOrderId
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
            SupplyAddressFormula__c
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
    * @param String orderId
    * @param String status
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
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Get active records by accountId
    * @param String accountId
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
            ServicePoint__r.SupplyAddress__c
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

    public List<Order> getRecordByOrderNumber(String orderNumber){
        return [Select id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c, ServicePoint__c,ServicePoint__r.Distributor__r.Name from Order where ordernumber = :orderNumber WITH SECURITY_ENFORCED];
    }
    public List<Order> getOrdersByOrderNumber(List<String> orderNumbers){
        return [SELECT id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c, ServicePoint__c,AccountId FROM Order where Ordernumber IN :orderNumbers WITH SECURITY_ENFORCED];
    }
    public List<Order> getRecordByOrderId(String recordId){
        return [Select id,phase__c,PrecheckResultSII__c,ProcessType__c,BillingProfile__c, Vat__c, ServicePoint__c,ServicePoint__r.Distributor__r.Name from Order where Id = :recordId WITH SECURITY_ENFORCED];
    }

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
    public String getRoleNameByRoleId(){

        String userId = UserInfo.getUserId();

        return [SELECT UserRole.Name 
        FROM User 
        WHERE Id = :userId
        WITH SECURITY_ENFORCED
        LIMIT 1].UserRole.Name;
    }

    public Order getDates(String recordId){
        return [SELECT Id, EffectiveDate__c, RetroactiveDate__c,ServicePoint__c,BillingProfile__c
        FROM Order
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];
    }

    public List<Order> getRecordsByIdWithFields(List<String> Ids, String fields) {
        String query = 'SELECT '+ fields +
                ' From Order where Id IN :Ids';
        List<Order> orders = Database.query(query);

        return orders;
    }
    
    //FINE SVILUPPI EVERIS

    public List<order> getOrderCreatedYesterday(){
        return [Select id,Account.Segment__c,account.SAPIntegrationID__c,account.RowIdSiebel__c,Account.Name,Account.Category__c,Account.CategoryCode__c,processType__c,OrderNumber,Recordtype.Name,Phase__c,CommodityFormula__c,OriginalOrderId,status, CreatedDate,Channel__c,Createdby.Name from Order where Createddate = Yesterday];
    }

    public static String getRecordTypesDeveloperNameById(Id id){
        String devName = [SELECT DeveloperName FROM RecordType WHERE id = :id].DeveloperName;
        return devName;
    }
	
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
            CancellationReason__c
        FROM Order
        WHERE ParentOrder__c = :parentOrderId
        AND QualityCall__c = true
        WITH SECURITY_ENFORCED
        ];
    }
    public List<Order>  getOrderByUsernamePassword(String username, String password) {
        HDT_LC_CanaleIVRNoShare qrs = new HDT_LC_CanaleIVRNoShare();
        
        return qrS.getOrderByUsernamePassword(username,password);

    
    }
	
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

    public List<Order> getOrderForActiveMonitoringCheck(String id){
        return [
            Select 
            id,
            AccountId,
            Account.ActiveMonitoring__c 
            from Order 
            Where id = :id
            AND Account.ActiveMonitoring__c = true
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Order> getOrderForComfort(String id){
        return [Select id,RecordType.DeveloperName from Order Where id = :id WITH SECURITY_ENFORCED];
    }
}