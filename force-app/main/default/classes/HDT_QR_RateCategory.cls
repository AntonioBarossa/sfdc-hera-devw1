public with sharing class HDT_QR_RateCategory {
    
    public static List<RateCategory__c> getRateList(String commodity,String distributorCode,String productname){
        return [Select id,CalculatedValue__c,DistributorCode__c,operatore__c from rateCategory__c where Commodity__c = :commodity  AND ProductName__c = :productname];
    }
}
