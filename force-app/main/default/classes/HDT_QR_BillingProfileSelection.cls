public with sharing class HDT_QR_BillingProfileSelection {
    public List<HDT_Generic_Record_Selection__mdt>  getConfigurationByName(String searchKey) {
        try{
            List<HDT_Generic_Record_Selection__mdt> config = [SELECT Id, Columns__c,Default_Search_Key__c,Fields__c,Max_Rows__c,Row_Limit__c,sObject__c,Where_Conditions__c 
            FROM HDT_Generic_Record_Selection__mdt WHERE DeveloperName =:searchKey WITH SECURITY_ENFORCED];
            return config;
        }catch(Exception ex){
            throw ex;
        }
    }
}
