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
    public static List<Account> getAccountByCode(List<Account> accountList, Set<String> codeSet){ 
        accountList = new List<Account>();
        accountList = [SELECT Id,CustomerCode__c FROM Account WHERE CustomerCode__c IN: codeSet WITH SECURITY_ENFORCED];
        return accountList;
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
    public static List<wrts_prcgvr__Activity__c> getActivityById(Set<String> actIdSet){
        List<wrts_prcgvr__Activity__c> activityList = new List<wrts_prcgvr__Activity__c>();
        activityList = [
            SELECT Id, ActivityOutcome__c,wrts_prcgvr__Status__c,ClosingNote__c,ClosingUserChannel__c,ClosingCreatorGroup__c,Case__c, Order__c
            FROM wrts_prcgvr__Activity__c
            //WHERE ServicePoint__r.ServicePointCode__c IN :podSet
            WHERE Id IN :actIdSet
            WITH SECURITY_ENFORCED
        ];
        return activityList;
    }
    public static List<User> getUserByLoginAdn(Set<String> userSet){
        List<User> userList = new List<User>();
        userList = [
            SELECT id,LoginADN__c,CreatorGroup__c, LoginChannel__c,Username
            FROM User
            //WHERE ServicePoint__r.ServicePointCode__c IN :podSet
            WHERE LoginADN__c IN :userSet
            WITH SECURITY_ENFORCED
        ];
        return userList;
    }
    public static List<Contract> getContractsByCodSapDgrer(List<Contract> contractList, Set<String> codeSet){
        contractList = new List<Contract>();
        contractList = [
            SELECT Id, ServicePoint__c, BillingProfile__c, AccountId, ServicePoint__r.ServicePointCode__c, ServicePoint__r.CommoditySector__c, SAPContractCode__c,Iniziativa__c
            FROM Contract
            WHERE SAPContractCode__c IN :codeSet
            WITH SECURITY_ENFORCED
        ];
        return contractList;
    }
    public static List<Contract> getContractsByPod(List<Contract> contractList, Set<String> podSet){
        contractList = new List<Contract>();
        contractList = [
            SELECT Id, ServicePoint__c, BillingProfile__c, AccountId, ServicePoint__r.ServicePointCode__c, ServicePoint__r.CommoditySector__c, SAPContractCode__c
            FROM Contract
            WHERE ServicePoint__r.ServicePointCode__c IN :podSet
            AND Status = 'Attivo'
            //WHERE SAPContractCode__c IN :codeSet
            WITH SECURITY_ENFORCED
        ];
        return contractList;
    }

    public static List<AccountContactRelation> getAccountContactRelationIdsList(List<AccountContactRelation> accContRelationList, Set<String> accountIdSet, String Roles){
        accContRelationList = new List<AccountContactRelation>();
        accContRelationList = [
            SELECT Id, AccountId, ContactId
            FROM AccountContactRelation
            WHERE AccountId IN: accountIdSet
            AND Roles = :Roles
            WITH SECURITY_ENFORCED
        ];
        return accContRelationList;
    }

    public static List<AccountContactRelation> getAccountContactRelationList(List<AccountContactRelation> accContRelationList, Set<String> accountIdSet, String Roles){
        accContRelationList = new List<AccountContactRelation>();
        accContRelationList = [
            SELECT Id, AccountId, ContactId, Contact.HomePhone, Contact.MobilePhone, Contact.Phone, Contact.Email, Contact.CertifiedEmail__c, Account.CustomerMarking__c, Contact.Fax, Account.FirstName__c, Account.LastName__c,
                   Account.FiscalCode__c, Account.VATNumber__c, Account.BillingCity, Account.BillingCountry, Account.BillingPlace__c, Account.BillingPostalCode, Account.BillingState, Account.BillingStreetNumber__c,
                   Account.BillingStreetName__c, Account.BillingAddressFormula__c, Account.BillingCityCode__c, Account.VATGroup__c, Account.VATGroupEndDate__c, Account.VATGroupStartDate__c, Account.IsVATGroupJoined__c, Account.Category__c
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
            SELECT Id, ParentId, ServicePoint__r.ServicePointCode__c,CompetentOffice__c
            FROM Case
            WHERE Type = :type
            AND ServicePoint__r.ServicePointCode__c IN :podSet
        ];
        return caseList;
    }

    public static List<BillingProfile__c> getBillingProfileByContractAccountCode(List<BillingProfile__c> billingProfileList, Set<String> codeSet){
        billingProfileList = new List<BillingProfile__c>();
        billingProfileList = [
            SELECT Id,BillSendingMethod__c, ElectronicInvoicingMethod__c, InvoiceEmailAddress__c, ElectronicInvoiceCertifiedEmailAddress__c,
                   InvoiceCertifiedEmailAddress__c, XMLType__c, SendCertifiedEmailConsentDate__c, OfficeSubjectCode__c, CareOf__c,
                   ReminderCertifiedEmailAddress__c, ReminderFlag__c, InvoicingCity__c, InvoicingCountry__c, InvoicingPlace__c, InvoicingPostalCode__c,
                   InvoicingProvince__c, InvoicingStreetNumber__c, InvoicingStreetName__c, InvoicingStreetNumberExtension__c, InvoicingAddressFormula__c,
                   ContractAccountCode__c
            FROM BillingProfile__c   
            WHERE ContractAccountCode__c = :codeSet 
            WITH SECURITY_ENFORCED
        ];
        return billingProfileList;
    }

    public static List<HDT_MassiveFieldsObjectMap__mdt> getMapFieldsObject(String processType){
        return [
            SELECT objectType__c, labelField__c, nameField__c, MasterLabel 
            FROM HDT_MassiveFieldsObjectMap__mdt 
            WHERE processType__c = :processType
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<HDT_MassiveFieldsObjectMap__mdt> getMapFieldsObjectByDeveloperName(String devName){
        return [
            SELECT objectType__c, labelField__c, nameField__c, MasterLabel 
            FROM HDT_MassiveFieldsObjectMap__mdt 
            WHERE DeveloperName LIKE :devName
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<Case> getAllCaseIdInList(List<Case> caseList){
        return [
            SELECT Id 
            FROM Case
            WHERE Id IN :caseList
            WITH SECURITY_ENFORCED
        ];
    }
    public static List<Order> getAllOrderIdInList(List<Order> orderList){
        return [
            SELECT Id 
            FROM Order
            WHERE Id IN :orderList
            WITH SECURITY_ENFORCED
        ];
    }

}