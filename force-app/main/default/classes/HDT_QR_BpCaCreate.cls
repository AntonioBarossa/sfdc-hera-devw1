public with sharing class HDT_QR_BpCaCreate 
{
    public List<Order> getRequestInformation(String orderId)
    {
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE,
            [SELECT Id,
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
            BillingProfile__r.DivergentSubject__r.MailingStreetName__c
            FROM Order
            WHERE Id = :orderId]
            );
        
        return securityDecision.getRecords();
    }


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
            AND CommodityFormula__c IN ('Acqua', 'Ambiente')
            AND ParentOrder__c != null
            AND (CustomerCode__c = NULL OR ContractAccountCode__c = NULL)
            AND Id != :orderId
            ]);

        return securityDecision.getRecords();
    }
}
