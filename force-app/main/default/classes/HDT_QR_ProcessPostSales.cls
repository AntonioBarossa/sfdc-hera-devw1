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

    public static List<Contract> getContracts(Set<String> podSet, List<Contract> contractList){
        contractList = new List<Contract>();
        contractList = [
            SELECT Id, ServicePoint__c, BillingProfile__c, AccountId, ServicePoint__r.ServicePointCode__c
            FROM Contract
            WHERE ServicePoint__r.ServicePointCode__c IN :podSet
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

}