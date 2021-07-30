public with sharing class HDT_QR_MatriceRemiCode {
    
    public static List<MatriceRemiCode__c> getAllRecord(){
        return [SELECT RemiCode__c, Comune__c, SalesCompany__c, Id FROM MatriceRemiCode__c];
    }
}
