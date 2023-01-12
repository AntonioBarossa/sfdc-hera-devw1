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
            Contact__r.Email,
            Contact__r.Phone,
            Contact__r.MobilePhone,
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
            ResidentialStreetNumberExtension__c,
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
            BillingStreetNumberExtension__c,
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
            SupplyType__c,
            SupplyStreetNumberExtension__c,
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

    public Order findOrderByTypeAndServicePointCode(Set<String> processTypeSet, String servicePointCode) {
        
        List<Order> orders = [
            SELECT 
            AccountId,
            CompanyOwner__c,
            Contact__c,
            Contact__r.Email,
            Contact__r.Phone,
            Contact__r.MobilePhone,
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
            SupplyType__c,
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
            Resident__c,
            SalesCompanyCode__c,
            SalesCompany__c
            FROM Order 
            WHERE DocumentalProcessType__c IN:processTypeSet
            AND ServicePointCodeFormula__c = :servicePointCode
            AND Phase__c != 'Annullato'
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];

        if (orders.size() > 0) {
            return orders[0];
        }

        return null;

    }

    /**
     * Recupera l'addizionale regionale da mandare al SII in base a: imposta (obbligatorio), comune o regione (opzionali)
     * TODO WAVE 3: configurare il metadato anche per le altre regioni (in wave 1 abbiamo solo Marche e Abruzzo).
     */
    public Double findRegionalAdditional(String tax, String city, String region) {
 
        List<HDT_RegionalAdditional__mdt> additionals = [
            SELECT
            Id,
            AdditionalValue__c
            FROM HDT_RegionalAdditional__mdt
            WHERE
            Tax__c = :tax
            AND (
                City__c = :city
                OR City__c = NULL
            )
            AND (
                Region__c = :region
                OR Region__c = NULL
            )
            WITH SECURITY_ENFORCED
        ];

        if (additionals.size() > 0) {
            return additionals[0].AdditionalValue__c;
        }

        return 0;
    }
}