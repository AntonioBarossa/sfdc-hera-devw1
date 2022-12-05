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

    public static List<RateCategory__c> getAllRecords(){
        return [select Id, CalculatedValue__c, Commodity__c, DistributorCode__c, ProductName__c, operatore__c, Fornitura__c, ExternalId__c from RateCategory__c WITH SECURITY_ENFORCED];
    }

    /* @frpanico 2022-11-22
    * Essendo possibile vendere offerte a Regolamentato
    * Gia dalla W1 e' necessario calcolare la RateCategory
    * Considerando anche il mercato
    */
    public static List<RateCategory__c> getRecordByMarket(String market)
    {
        return [SELECT Id,CalculatedValue__c,DistributorCode__c,Operatore__c FROM RateCategory__c WHERE Market__c = :market WITH SECURITY_ENFORCED];
    }
}
