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
            SalesCompany__c,
            Campaign__c,
            Campaign__r.Name,
            ContractReference__c,
            OrderReference__c,
            ContractReference__r.ContractNumber,
            OrderReference__r.OrderNumber
            // ActivationStreetName__c,
            // ActivationCity__c,
            // ActivationPostalCode__c,
            // ActivationCountry__c,
            // ActivationProvince__c,
            // ActivationStreetNumberExtension__c,
            // ActivationStreetNumber__c
            FROM Order 
            WHERE Id = :orderId
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
            Phase__c
            FROM
            Order
            WHERE ParentOrder__c = :parentOrderId
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
            Phase__c
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
            RecordType.DeveloperName
            FROM
            Order
            WHERE AccountId = :accountId
            AND RecordType.DeveloperName != null
            AND RecordType.DeveloperName != 'HDT_RT_OrderDossier'
            AND SBQQ__Quote__r.IsVAS__c != true
            AND SBQQ__Quote__r.AmendmentAllowed__c != true
            AND Status IN ('In Lavorazione','Draft')
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Order> getRecordByOrderNumber(String orderNumber){
        return [Select id,phase__c from Order where ordernumber = :orderNumber WITH SECURITY_ENFORCED];
    }

}