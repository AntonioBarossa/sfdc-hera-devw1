public with sharing class HDT_QR_ProcessPostSales {

    public static Id getRecordTypeId(String developerName){
        //return [
        //    SELECT Id
        //    FROM RecordType
        //    WHERE DeveloperName = :developerName
        //    WITH SECURITY_ENFORCED
        //    LIMIT 1
        //].Id;
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }

    public static List<Contract> getContracts(List<Contract> contractList, Set<String> codeSet){
        contractList = new List<Contract>();
        contractList = [
            SELECT Id, ServicePoint__c, BillingProfile__c, AccountId, ServicePoint__r.ServicePointCode__c, ServicePoint__r.CommoditySector__c, SAPContractCode__c
            FROM Contract
            //WHERE ServicePoint__r.ServicePointCode__c IN :podSet
            WHERE SAPContractCode__c IN :codeSet
            WITH SECURITY_ENFORCED
        ];
        return contractList;
    }

    public static List<AccountContactRelation> getAccountContactRelationList(List<AccountContactRelation> accContRelationList, Set<String> accountIdSet, String Roles){
        accContRelationList = new List<AccountContactRelation>();
        accContRelationList = [
            SELECT Id, AccountId, ContactId, Contact.HomePhone, Contact.MobilePhone, Contact.Email, Contact.CertifiedEmail__c, Account.CustomerMarking__c, Contact.Fax, Account.FirstName__c, Account.LastName__c,
                   Account.FiscalCode__c, Account.VATNumber__c, Account.BillingCity, Account.BillingCountry, Account.BillingPlace__c, Account.BillingPostalCode, Account.BillingState, Account.BillingStreetNumber__c,
                   Account.BillingStreetName__c, Account.BillingAddressFormula__c, Account.VATGroup__c, Account.VATGroupEndDate__c, Account.VATGroupStartDate__c, Account.IsVATGroupJoined__c
            FROM AccountContactRelation
            WHERE AccountId IN: accountIdSet
            AND Roles = :Roles
            WITH SECURITY_ENFORCED
        ];
        return accContRelationList;
    }

    public static List<Order> getOrderByOrderNumber(List<Order> orderList, List<String> orderNumberList){
        orderList = new List<Order>();
        orderList = [
            SELECT Id, OrderNumber
            FROM Order
            WHERE OrderNumber IN :orderNumberList
            WITH SECURITY_ENFORCED
        ];
        return orderList;
    }

    public static List<Case> getCaseByServicePointCode(List<Case> caseList, Set<String> podSet, String type){
        caseList = new List<Case>();
        caseList = [
            SELECT Id, ParentId, ServicePoint__r.ServicePointCode__c
            FROM Case
            WHERE Type = :type
            AND ServicePoint__r.ServicePointCode__c IN :podSet
        ];
        return caseList;
    }

    public static List<Contract> getContractsByContractAccountCode(List<Contract> contractList, Set<String> codeSet){
        contractList = new List<Contract>();
        //contractList = [
        //    SELECT Id,BillingProfile__c.BillSendingMethod__c, BillingProfile__c.ElectronicInvoicingMethod__c, BillingProfile__c.InvoiceEmailAddress__c, BillingProfile__c.ElectronicInvoiceCertifiedEmailAddress__c,
        //           BillingProfile__c.InvoiceCertifiedEmailAddress__c, BillingProfile__c.XMLType__c, BillingProfile__c.SendCertifiedEmailConsentDate__c, BillingProfile__c.OfficeSubjectCode__c, BillingProfile__c.CareOf__c,
        //           BillingProfile__c.ReminderCertifiedEmailAddress__c, BillingProfile__c.ReminderFlag__c, BillingProfile__c.InvoicingCity__c, BillingProfile__c.InvoicingCountry__c, BillingProfile__c.InvoicingPlace__c, BillingProfile__c.InvoicingPostalCode__c,
        //           BillingProfile__c.InvoicingProvince__c, BillingProfile__c.InvoicingStreetNumber__c, BillingProfile__c.InvoicingStreetName__c, BillingProfile__c.InvoicingStreetNumberExtension__c, BillingProfile__c.InvoicingAddressFormula__c  
        //    FROM BillingProfile__c   
        //    WHERE ContractAccountCode__c = :codeSet 
        //    WITH SECURITY_ENFORCED
        //];
        return contractList;
    }

}