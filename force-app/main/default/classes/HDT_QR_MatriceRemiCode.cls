/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 29/07/2021
* @description HDT_QR_MatriceRemiCode
* @history Lorenzo – 29/07/2021 – created class
*/

public with sharing class HDT_QR_MatriceRemiCode {
    
    public static List<MatriceRemiCode__c> getAllRecord(){
        return [SELECT RemiCode__c, Comune__c, SalesCompany__c, Id, VATNumberUdb__c FROM MatriceRemiCode__c WITH SECURITY_ENFORCED];
    }

    public static List<MatriceRemiCode__c> getAllRemiConfiguration(){
        return [SELECT RemiCode__c, Comune__c, SalesCompany__c, Id, VATNumberUdb__c FROM MatriceRemiCode__c where SalesCompany__c = null WITH SECURITY_ENFORCED];
    }

    public static List<MatriceRemiCode__c> getAllPartitaUdbConfiguration(set<String> comuni){
        return [SELECT RemiCode__c, Comune__c, SalesCompany__c, Id, VATNumberUdb__c FROM MatriceRemiCode__c where SalesCompany__c != null and comune__c IN :comuni WITH SECURITY_ENFORCED];
    }


}
