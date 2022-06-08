@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class HDT_LC_ActiveRepentant {

    @AuraEnabled
    public static List<PeriodsTable__c> getPeriods(String comune, String sottotipo){
        List<PeriodsTable__c> periods =  [SELECT Id, PeriodXCriteria__c, EffectiveDate__c, DaysX__c, PeriodYCriteria__c, DaysY__c, PopupYText__c, PopupZText__c 
                                            FROM PeriodsTable__c WHERE Municipality__c = :comune AND Subtype__c =:sottotipo LIMIT 1];
        return periods;
    }

    @AuraEnabled
    public static List<TermsTable__c> getTerms(String comune){
        List<TermsTable__c> terms =  [SELECT Id, Municipality__c, Day__c, Month__c FROM TermsTable__c WHERE Municipality__c = :comune ORDER BY Month__c ASC LIMIT 1];
        return terms;
    }

}
