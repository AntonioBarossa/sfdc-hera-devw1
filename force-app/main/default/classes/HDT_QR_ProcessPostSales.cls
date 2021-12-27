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
            SELECT AccountId, ContactId
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

}