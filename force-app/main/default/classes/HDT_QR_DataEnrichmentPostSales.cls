public with sharing class HDT_QR_DataEnrichmentPostSales {


    public List<HDT_DataEnrichmentTransocode__mdt> getTranscodeConfig(){

        return [SELECT Id,
        SapField__c,
        SfdcField__c,
        IsNumber__c,
        Precision__c,
        IsTranscode__c,
        Method__c
        FROM HDT_DataEnrichmentTransocode__mdt
        WITH SECURITY_ENFORCED
        ];

    }

    public BillingProfile__c getBillingProfileIdBySapCode(String sapCode){

        BillingProfile__c billingProfile = new BillingProfile__c();

        billingProfile = [SELECT Id,
        SubjectCode__c,
        CIG__c,
        CUP__c,
        XMLType__c,
        ElectronicInvoiceCertifiedEmailAddress__c,
        ElectronicInvoicingMethod__c,
        SendCertifiedEmailConsentDate__c,
        BillSendingMethod__c,
        InvoiceEmailAddress__c,
        InvoiceCertifiedEmailAddress__c,
        InvoicingStreetName__c,
        InvoicingStreetNumber__c,
        InvoicingStreetNumberExtension__c,
        InvoicingCity__c,
        InvoicingProvince__c,
        InvoicingPostalCode__c,
        InvoicingCountry__c,
        InvoicingAddressFormula__c
        FROM BillingProfile__c
        WHERE ContractAccountCode__c = :sapCode
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];

        return billingProfile;

    }

    public BillingProfile__c getBillingProfileInvoiceData(String recordId){

        BillingProfile__c billingProfile = new BillingProfile__c();

        billingProfile = [SELECT Id,
        InvoicingStreetName__c,
        InvoicingStreetNumber__c,
        InvoicingStreetNumberExtension__c,
        InvoicingCity__c,
        InvoicingProvince__c,
        InvoicingPostalCode__c,
        InvoicingCountry__c
        FROM BillingProfile__c
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1];

        return billingProfile;


    }

    public ServicePoint__c getServicePointData(String recordId){

        ServicePoint__c servicePoint = new ServicePoint__c();

        servicePoint = [SELECT Id,
        SupplyType__c,
        Disconnectable__c,
        DisconnectibilityType__c
        FROM ServicePoint__c
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1
        ];

        return servicePoint;

    }

    public Contract getContractData(String sapContractCode){

        List<Contract> contracts = [SELECT Id
        FROM Contract
        WHERE SAPContractCode__c = :sapContractCode
        WITH SECURITY_ENFORCED
        ];

        return contracts.isEmpty() ? new Contract() : contracts[0];
    }
}