/**@frpanico 2022-09-23
* Test Covered by HDT_WS_BpCaCreateTst
* Query class for the Bp Ca Create Module */
public with sharing class HDT_QR_BpCaCreate 
{
    /* This method queries all the information, starting from the input order, needed to generate the request */
    public List<Order> getRequestInformation(String orderId)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id,
            ParentOrder__c,
            Account.FirstName__c,
            Account.LastName__c,
            Account.CustomerCode__c,
            Account.CustomerType__c,
            Account.Category__c,
            Account.PrimaryEmail__c,
            Account.CustomerMarking__c,
            Account.FiscalCode__c,
            Account.VatNumber__c,
            Account.BillingCity,
            Account.BillingCountry,
            Account.BuildingFloor__c,
            Account.BillingStreetNumber__c,
            Account.BillingStreetNumberExtension__c,
            Account.BillingPostalCode,
            Account.BillingState,
            Account.BillingStreet,
            Account.BillingStreetName__c,
            Account.IsVatGroupJoined__c,
            Account.VATGroup__c,
            Account.VATGroupStartDate__c,
            Account.VATGroupEndDate__c,
            Contact__r.MobilePhone,
            Contact__r.Fax,
            Contact__r.Email,
            Contact__r.Phone,
            BillingProfile__r.ContractAccountCode__c,
            BillingProfile__r.InvoiceEmailAddress__c,
            BillingProfile__r.InvoiceCertifiedEmailAddress__c,
            BillingProfile__r.BillSendingMethod__c,
            BillingProfile__r.ElectronicInvoiceCertifiedEmailAddress__c,
            BillingProfile__r.ReminderFlag__c,
            BillingProfile__r.IbanABI__c,
            BillingProfile__r.IbanCAB__c,
            BillingProfile__r.IbanCodeNumber__c,
            BillingProfile__r.BankAccountSignatoryFiscalCode__c,
            BillingProfile__r.IbanCIN__c,
            BillingProfile__r.IBAN__c,
            BillingProfile__r.BankAccountSignatoryLastName__c,
            BillingProfile__r.BankAccountSignatoryFirstName__c,
            BillingProfile__r.PaymentConditions__c,
            BillingProfile__r.PaymentMethod__c,
            BillingProfile__r.InvoicingCity__c,
            BillingProfile__r.InvoicingCountry__c,
            BillingProfile__r.InvoicingStreetNumber__c,
            BillingProfile__r.InvoicingStreetNumberExtension__c,
            BillingProfile__r.InvoicingPostalCode__c,
            BillingProfile__r.InvoicingProvince__c,
            BillingProfile__r.InvoicingStreetName__c,
            BillingProfile__r.CareOf__c,
            BillingProfile__r.OfficeSubjectCode__c,
            BillingProfile__r.XMLType__c,
            BillingProfile__r.ElectronicInvoicingMethod__c,
            BillingProfile__r.DivergentSubject__c,
            BillingProfile__r.DivergentSubject__r.FirstName,
            BillingProfile__r.DivergentSubject__r.FiscalCode__c,
            BillingProfile__r.DivergentSubject__r.Fax,
            BillingProfile__r.DivergentSubject__r.Email,
            BillingProfile__r.DivergentSubject__r.VATNumber__c,
            BillingProfile__r.DivergentSubject__r.MobilePhone,
            BillingProfile__r.DivergentSubject__r.Phone,
            BillingProfile__r.DivergentSubject__r.ContactCode__c,
            BillingProfile__r.DivergentSubject__r.LastName,
            BillingProfile__r.DivergentSubject__r.MailingCity,
            BillingProfile__r.DivergentSubject__r.MailingCountry,
            BillingProfile__r.DivergentSubject__r.MailingStreetNumber__c,
            BillingProfile__r.DivergentSubject__r.MailingStreetNumberExtension__c,
            BillingProfile__r.DivergentSubject__r.MailingPostalCode,
            BillingProfile__r.DivergentSubject__r.MailingState,
            BillingProfile__r.DivergentSubject__r.MailingStreetName__c,
            BillingProfile__r.IbanCountry__c,
            BillingProfile__r.CreateContractAccount__c,
            BillingProfile__r.IbanCIN_IBAN__c
            FROM Order
            WHERE Id = :orderId]
            );
        
        return securityDecision.getRecords();
    }

    /* This method queries all orders with same Billing Profile (and Account) that need to be updated
    * SaleId parameter is not used yet but it can be useful to eventually restrict the query to orders
    * linked to the same Sale
    * update 2022-10-10 this logic is not need for "Ambiente" commodity
    */
    public List<Order> getOtherOrdersToUpdate(String orderId, String saleId, String billingProfileId)
    {
        SObjectAccessDecision securityDecision =
            Security.stripInaccessible(AccessType.READABLE, 
            [SELECT Id,
            AccountId,
            Phase__c,
            BillingProfile__c,
            CustomerCode__c,
            ContractAccountCode__c
            FROM Order
            WHERE BillingProfile__c = :billingProfileId
            AND Status NOT IN ('Activated', 'Annullato')
            AND CommodityFormula__c IN ('Acqua')
            AND ParentOrder__c != null
            AND (CustomerCode__c = NULL OR ContractAccountCode__c = NULL)
            AND Id != :orderId
            ]);

        return securityDecision.getRecords();
    }

    public List<BillingProfile__c> getBillingProfileFromId(Id billingId){
        return [SELECT Id,
        AccountClassCode__c,
        AccountClass__c,
        Account__c,
        ActivationDate__c,
        BankAccountSignatoryCustomerCode__c,
        BankAccountSignatoryFirstName__c,
        BankAccountSignatoryFiscalCode__c,
        BankAccountSignatoryLastName__c,
        BankAgency__c,
        BankName__c,
        BillSendingMethod__c,
        CIG__c,
        CUP__c,
        CareOf__c,
        CompanyOwner__c,
        Contact__c,
        ContractAccountCode__c,
        CreateContractAccount__c,
        DirectDebitStatusFormula__c,
        DirectDebitStatus__c,
        DivergentSubject__c,
        ElectronicInvoiceCertifiedEmailAddress__c,
        ElectronicInvoicingMethod__c,
        GlobalMigrationKey__c,
        IBAN__c,
        IbanABI__c,
        IbanCAB__c,
        IbanCIN_IBAN__c,
        IbanCIN__c,
        IbanCodeNumber__c,
        IbanCountry__c,
        IbanIsForeign__c,
        InvoiceCertifiedEmailAddress__c,
        InvoiceEmailAddress__c,
        InvoicingAddessIsForeign__c,
        InvoicingAddressFormula__c,
        InvoicingCityCode__c,
        InvoicingCity__c,
        InvoicingCountry__c,
        InvoicingIsAddressVerified__c,
        InvoicingPlaceCode__c,
        InvoicingPlace__c,
        InvoicingPostalCode__c,
        InvoicingProvince__c,
        InvoicingStreetCode__c,
        InvoicingStreetName__c,
        InvoicingStreetNumberExtension__c,
        InvoicingStreetNumber__c,
        IsDigitalMarking__c,
        IsInactiveSAPContractAccount__c,
        IsMigrated__c,
        IsWrongFiscalData__c,
        LegalAgent__c,
        OfficeSubjectCode__c,
        OtherPayerName__c,
        OtherPayer__c,
        PaymentConditions__c,
        PaymentMethod__c,
        ReminderCertifiedEmailAddress__c,
        ReminderFlag__c,
        RevocationDate__c,
        SendCertifiedEmailConsentDate__c,
        SignatoryType__c,
        Status__c,
        SubjectCodeEndDate__c,
        SubjectCodeStartDate__c,
        SubjectCode__c,
        XMLType__c,
        CreaCaFormula__c,
        IsThirtyDaysDue__c,
        Account__r.CustomerCode__c,
        Account__r.FirstName__c,
        Account__r.LastName__c,
        Account__r.CustomerType__c,
        Account__r.Category__c,
        Account__r.PrimaryEmail__c,
        Account__r.CustomerMarking__c,
        Account__r.FiscalCode__c,
        Account__r.VATNumber__c,
        DivergentSubject__r.FirstName,
        DivergentSubject__r.Fax,
        DivergentSubject__r.FiscalCode__c,
        DivergentSubject__r.Email,
        DivergentSubject__r.VATNumber__c,
        DivergentSubject__r.MobilePhone,
        DivergentSubject__r.Phone,
        DivergentSubject__r.ContactCode__c,
        DivergentSubject__r.LastName,
        DivergentSubject__r.MailingCity,
        DivergentSubject__r.MailingCountry,
        DivergentSubject__r.MailingStreetNumber__c,
        DivergentSubject__r.MailingStreetNumberExtension__c,
        DivergentSubject__r.MailingPostalCode,
        DivergentSubject__r.MailingState,
        DivergentSubject__r.MailingStreetName__c
        FROM BillingProfile__c
        WHERE Id=:billingId];
    }
}
