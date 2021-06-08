public with sharing class HDT_QR_AnagAlignment {

    public ServicePoint__c findServicePointByCode(String servicePointCode) {
 
        List<ServicePoint__c> servicePoints = [
            SELECT
            Id,
            Account__c
            FROM ServicePoint__c
            WHERE
            ServicePointCode__c = :servicePointCode
            WITH SECURITY_ENFORCED
        ];

        if (servicePoints.size() > 0) {
            return servicePoints[0];
        }

        return null;
    }
    
    public Order findOrderByDistributorPracticeCode(String distributorPracticeCode) {
        
        List<Order> orders = [
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
            Status,
            ContractSigned__c,
            SignedDate__c,
            SignatureMethod__c,
            DocSendingMethod__c,
            CreatedDate,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            ContractId,
            ServicePoint__r.CommoditySector__c,
            ServicePoint__r.Account__c,
            ServicePoint__r.MeterClass__c,
            ServicePoint__r.UseTypeEnergy__c,
            ServicePoint__r.UseCategory__c,
            BillingProfile__c,
            OrderNumber,
            Phase__c, 
            RequestOption__c,
            WaiverRightAfterthought__c,
            MaxAfterthoughtDate__c,
            PreviousTrader__c,
            VolturaThirdTrader__c,
            SalesCompany__c,
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
            ActivationStreetNumber__c
            //ImplantType__c
            FROM Order 
            WHERE DistributorPracticeCode__c = :distributorPracticeCode
            WITH SECURITY_ENFORCED
        ];

        if (orders.size() > 0) {
            return orders[0];
        }

        return null;

    }

    public Order findOrderByTypeAndServicePointCode(String processType, String servicePointCode) {
        
        List<Order> orders = [
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
            Status,
            ContractSigned__c,
            SignedDate__c,
            SignatureMethod__c,
            DocSendingMethod__c,
            CreatedDate,
            ServicePoint__c,
            ServicePoint__r.ServicePointCode__c,
            ContractId,
            ServicePoint__r.CommoditySector__c,
            ServicePoint__r.Account__c,
            ServicePoint__r.MeterClass__c,
            ServicePoint__r.UseTypeEnergy__c,
            ServicePoint__r.UseCategory__c,
            BillingProfile__c,
            OrderNumber,
            Phase__c, 
            RequestOption__c,
            WaiverRightAfterthought__c,
            MaxAfterthoughtDate__c,
            PreviousTrader__c,
            VolturaThirdTrader__c,
            SalesCompany__c,
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
            ActivationStreetNumber__c
            //ImplantType__c
            FROM Order 
            WHERE ProcessType__c = :processType
            AND ServicePointCodeFormula__c = :servicePointCode
            WITH SECURITY_ENFORCED
        ];

        if (orders.size() > 0) {
            return orders[0];
        }

        return null;

    }


}
