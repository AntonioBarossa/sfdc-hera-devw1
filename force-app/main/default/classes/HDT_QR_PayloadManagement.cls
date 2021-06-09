public with sharing class HDT_QR_PayloadManagement {
    public HDT_QR_PayloadManagement() {

    }
    public List<HDT_HcmCityException__mdt> getHcmCityExceptionByName(String city){
        if(String.isBlank(city)) return null;
        city = String.escapeSingleQuotes(city);
        return [SELECT City__c, Commodity__c FROM HDT_HcmCityException__mdt WHERE City__c=:city];
    }
}
