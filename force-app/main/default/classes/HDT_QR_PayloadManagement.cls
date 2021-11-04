public with sharing class HDT_QR_PayloadManagement {
    
    public List<HDT_HcmCityException__mdt> getHcmCityExceptionByName(String city, String commodity){
        if(String.isBlank(city) || String.isBlank(commodity)){
            return null;
        }
        city = String.escapeSingleQuotes(city);
        city = city.toUpperCase();
        return [SELECT City__c, Commodity__c FROM HDT_HcmCityException__mdt WHERE City__c=:city AND Commodity__c=:commodity WITH SECURITY_ENFORCED];
    }

    public List<HDT_DistributorExceptionHC__mdt> getHcDistributorExceptionByName(String distributorName){
        if(String.isBlank(distributorName)) {
            return null;
        }
        distributorName = String.escapeSingleQuotes(distributorName);
        distributorName = distributorName.toUpperCase();
        return [SELECT DistributorName__c FROM HDT_DistributorExceptionHC__mdt WHERE DistributorName__c=:distributorName WITH SECURITY_ENFORCED];
    }
}
