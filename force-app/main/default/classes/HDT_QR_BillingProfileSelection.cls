public with sharing class HDT_QR_BillingProfileSelection {
    public List<HDT_Generic_Record_Selection__mdt>  getConfigurationByName(String searchKey) {

        List<HDT_Generic_Record_Selection__mdt> config = [SELECT Id,Distinct__c,Query_Type__c,Columns__c,Default_Search_Key__c,Fields__c,Max_Rows__c,Row_Limit__c,sObject__c,Where_Conditions__c 
        FROM HDT_Generic_Record_Selection__mdt WHERE DeveloperName =:searchKey WITH SECURITY_ENFORCED];
        return config;

    }
}