public inherited sharing class HDT_QR_ProcessSales {

    public static List<Account> getAccountList(Set<String> fiscalCodeSet, Set<String> vatNumberSet, Set<String> marcaturaSet, Set<String> csnSet){
        return [
            SELECT Id, CustomerCode__c, FiscalCode__c, VATNumber__c, CustomerMarking__c
            FROM Account
            WHERE CustomerCode__c IN :csnSet
            OR (
                FiscalCode__c IN :fiscalCodeSet
                AND VATNumber__c IN :vatNumberSet
                AND CustomerMarking__c IN :marcaturaSet
                )
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<BillingProfile__c> getBillingProfileList(Set<String> contoContrattualeSet){
        return [
            SELECT Id, ContractAccountCode__c
            FROM BillingProfile__c
            WHERE ContractAccountCode__c IN: contoContrattualeSet
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<AccountContactRelation> getAccountContactRelationByAccountId(List<AccountContactRelation> acrList, List<Id> accountIdsList){
        acrList = new List<AccountContactRelation>();
        acrList = [
            SELECT Id, Roles
            FROM AccountContactRelation
            WHERE AccountId IN :accountIdsList
            WITH SECURITY_ENFORCED
        ];
        return acrList;
    }

    public static List<ServicePoint__c> getServicePointList(List<ServicePoint__c> servicePointList, List<Id> servPointIdsList){
        servicePointList = new List<ServicePoint__c>();
        servicePointList = [
            SELECT Id, MeterStatus__c, Distributor__c, Account__c, ServicePointCode__c, Name
            FROM ServicePoint__c
            WHERE Id = :servPointIdsList
            WITH SECURITY_ENFORCED
        ];
        return servicePointList;
    }

    public static List<AccountContactRelation> getAccountContactRelationList(List<AccountContactRelation> accContRelList, List<Id> accountIdsList){
        accContRelList = new List<AccountContactRelation>();
        accContRelList = [
            SELECT AccountId, Account.Name, Account.RecordTypeId, Account.LastName__c, Account.FirstName__c, Account.Category__c,
                   Account.Fax, Account.CustomerMarking__c, Account.FiscalCode__c, Account.Vatnumber__c, Account.BillingCity,
                   Account.BillingCountry, Account.BillingStreetToponym__c, Account.BillingStreetNumber__c, Account.BillingPostalCode,
                   Account.BillingState, Account.BillingStreetName__c, Account.CustomerCode__c, Account.MobilePhone__c, Account.BuildingFloor__c,
                   Account.PrimaryEmail__c, Account.VATGroup__c, Account.VATGroupStartDate__c, Account.VATGroupEndDate__c,
                   ContactId, Contact.MobilePhone, Contact.email, Contact.fiscalCode__c, Contact.CertifiedEmail__c
            FROM AccountContactRelation
            WHERE AccountId IN :accountIdsList
            WITH SECURITY_ENFORCED
        ];
        return accContRelList;
    }
}