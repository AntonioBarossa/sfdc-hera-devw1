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
            CompanyOwner__c,
            Contact__c,
            Status,
            OrderNumber,
            Phase__c, 
            CommodityFormula__c,
            // Campi sezione Dati Residenza
            ResidentialCity__c,
            ResidentialCityCode__c,
            ResidentialCountry__c,
            ResidentialIsAddressVerified__c,
            ResidentialPlace__c,
            ResidentialPlaceCode__c,
            ResidentialPostalCode__c,
            ResidentialState__c,
            ResidentialStreetName__c,
            ResidentialStreetNumber__c,
            ResidentialStreetToponym__c,
            // Campi sezione Dati Esazione
            BillingProfile__c,
            BillingCity__c,
            BillingCityCode__c,
            BillingCountry__c,
            BillingIsAddressVerified__c,
            BillingPlace__c,
            BillingPlaceCode__c,
            BillingPostalCode__c,
            BillingProvince__c,
            BillingStreetName__c,
            BillingStreetNumber__c,
            BillingStreetToponym__c,
            // Campi sezione Dati Fornitura
            SupplyCity__c,
            SupplyCityCode__c,
            SupplyCountry__c,
            SupplyIsAddressVerified__c,
            SupplyPlace__c,
            SupplyPlaceCode__c,
            SupplyPostalCode__c,
            SupplyState__c,
            SupplyStreetName__c,
            SupplyStreetNumber__c,
            SupplyStreetToponym__c,
            // Campi sezione Tributi e Dati Commerciali
            VAT__c,
            ExciseEle__c,
            ExciseGAS__c,
            AtecoCode__c,
            Market__c,
            ContractId,
            ServicePoint__c,
            // Campi sezione Altri Dati
            Disconnectable__c,
            SubjectCode__c,
            DistributorCode__c,
            CustomerName__c,
            CustomerLastName__c,
            CustomerVATNumber__c,
            CustomerFiscalCode__c,
            Resident__c
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
            CompanyOwner__c,
            Contact__c,
            Status,
            OrderNumber,
            Phase__c, 
            CommodityFormula__c,
            // Campi sezione Dati Residenza
            ResidentialCity__c,
            ResidentialCityCode__c,
            ResidentialCountry__c,
            ResidentialIsAddressVerified__c,
            ResidentialPlace__c,
            ResidentialPostalCode__c,
            ResidentialState__c,
            ResidentialStreetName__c,
            ResidentialStreetNumber__c,
            ResidentialStreetToponym__c,
            // Campi sezione Dati Esazione
            BillingProfile__c,
            BillingCity__c,
            BillingCityCode__c,
            BillingCountry__c,
            BillingIsAddressVerified__c,
            BillingPlace__c,
            BillingPostalCode__c,
            BillingProvince__c,
            BillingStreetName__c,
            BillingStreetNumber__c,
            BillingStreetToponym__c,
            // Campi sezione Dati Fornitura
            SupplyCity__c,
            SupplyCityCode__c,
            SupplyCountry__c,
            SupplyIsAddressVerified__c,
            SupplyPlace__c,
            SupplyPlaceCode__c,
            SupplyPostalCode__c,
            SupplyState__c,
            SupplyStreetName__c,
            SupplyStreetNumber__c,
            SupplyStreetToponym__c,
            // Campi sezione Tributi e Dati Commerciali
            VAT__c,
            ExciseEle__c,
            ExciseGAS__c,
            AtecoCode__c,
            Market__c,
            ContractId,
            ServicePoint__c,
            // Campi sezione Altri Dati
            Disconnectable__c,
            SubjectCode__c,
            DistributorCode__c,
            CustomerName__c,
            CustomerLastName__c,
            CustomerVATNumber__c,
            CustomerFiscalCode__c,
            Resident__c
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