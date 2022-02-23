public with sharing class HDT_LC_CaseTabManagement {
    @AuraEnabled
    public static Map<String,String> getCase(Id caseId){
        Case recordCase = [SELECT Id, Lead__c,AccountId FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
        Map<String,String> mapCase = new Map<String,String>();
        if(recordCase != null){
            mapCase.put('Lead', recordCase.Lead__c);
            mapCase.put('Account', recordCase.AccountId);
        }
        return mapCase;
    }
}
