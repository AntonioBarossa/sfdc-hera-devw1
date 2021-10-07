/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 29/07/2021
* @description HDT_QR_RateCategory
* @history Lorenzo – 29/07/2021 – created class
*/
public with sharing class HDT_QR_RateCategory {
    
    public static List<RateCategory__c> getRateList(String commodity,String distributorCode,String productname,string typ){
        return [Select id,CalculatedValue__c,DistributorCode__c,operatore__c from rateCategory__c where Commodity__c = :commodity  AND ProductName__c = :productname AND Fornitura__c= :typ WITH SECURITY_ENFORCED];
    }
}
