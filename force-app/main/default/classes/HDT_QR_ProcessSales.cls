public inherited sharing class HDT_QR_ProcessSales {

        //List<Account> accountList = [
        //    SELECT Id, FiscalCode__c, VATNumber__c, CustomerMarking__c
        //    FROM Account
        //    WHERE FiscalCode__c IN :fiscalCodeSet
        //    AND VATNumber__c IN :vatNumberSet
        //    AND CustomerMarking__c IN :marcaturaSet
        //];
//
        //List<BillingProfile__c> billingProfileList = [
        //    SELECT Id, ContractAccountCode__c
        //    FROM BillingProfile__c
        //    WHERE ContractAccountCode__c IN: contoContrattualeSet
        //];

    public static List<AccountContactRelation> getAccountContactRelationByAccountId(List<AccountContactRelation> acrList, List<Id> accountIdsList){
        acrList = new List<AccountContactRelation>();
        acrList = [
            SELECT Id, Roles
            FROM AccountContactRelation
            WHERE AccountId IN :accountIdsList
        ];
        return acrList;
    }

}