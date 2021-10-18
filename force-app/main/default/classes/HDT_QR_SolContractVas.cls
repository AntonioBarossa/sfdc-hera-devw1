public with sharing class HDT_QR_SolContractVas {
    public static List<SObject> getContractWithOffer(String accountId){
        if(Contract.SObjectType.getDescribe().isAccessible() && SBQQ__Subscription__c.SObjectType.getDescribe().isAccessible()){
            String queryString = 'SELECT Id, SAPContractCode__c,(select SBQQ__Product__r.ProductCode, SBQQ__Product__r.Version__c from SBQQ__Subscriptions__r where SBQQ__Product__r.Family=\'Offerta commerciale\') FROM Contract WHERE Status = \'Attivo\' AND AccountId = \''+String.escapeSingleQuotes(accountId)+'\'';
            return Database.query(queryString);
        }else {
            return new List<SObject>();
        }
    }

    public static List<SObject> getProductOptionVas(Set<String> offerSet){
        if(offerSet.size()==0)return null;
        if(SBQQ__ProductOption__c.SObjectType.getDescribe().isAccessible()){
            return [SELECT Id,SBQQ__ConfiguredSKU__r.ProductCode,Version__c,SBQQ__ConfiguredSKU__r.Version__c, SBQQ__ProductName__c from SBQQ__ProductOption__c where SBQQ__ProductName__c ='Analisi Consumi' AND SBQQ__ConfiguredSKU__r.ProductCode in:offerSet WITH SECURITY_ENFORCED];
        }else {
            return null;
        }
        
    }

}
