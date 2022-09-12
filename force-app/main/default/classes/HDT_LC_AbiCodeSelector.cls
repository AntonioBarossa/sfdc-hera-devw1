public with sharing class HDT_LC_AbiCodeSelector {
    @AuraEnabled(cacheable=false)
    public static List<SObject> getData(String searchString){
        if(String.isNotBlank(searchString)){
            List<List<SObject>> searchList = [FIND :searchString IN ALL FIELDS RETURNING AbiCode__c(IbanABI__c,BankName__c WHERE Active__c=true)];
            if(!searchList.isEmpty()){
                return searchList[0];
            }else {
                return null;
            }
        }else {
            return [SELECT IbanABI__c,BankName__c FROM AbiCode__c WHERE Active__c = true LIMIT 100];
        }
    }
}
