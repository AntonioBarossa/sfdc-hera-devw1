/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 08-06-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class HDT_LC_ActiveRepentant {

    @AuraEnabled
    public Date dateX {get;set;}

    @AuraEnabled
    public Date dateY {get;set;}

    @AuraEnabled
    public Integer missedDue {get;set;}

    @AuraEnabled
    public String declineSupport {get;set;}

    @AuraEnabled
    public String bloccoCalcolo {get;set;}



    @AuraEnabled
    public static List<TermTable__c> getPeriods(String comune, String sottotipo){
        List<TermTable__c> periods =  [SELECT Id, CriteriaX__c, EffectiveDate__c, DayX__c, CriteriaY__c, DayY__c, PopupY__c, PopupZ__c 
                                            FROM TermTable__c WHERE City__c = :comune AND Subtype__c =:sottotipo LIMIT 1];
        return periods;
    }

    @AuraEnabled
    public static List<TermsAdministration__c> getTerms(String comune){
        List<TermsAdministration__c> terms =  [SELECT Id, City__c, Day__c, Month__c FROM TermsAdministration__c WHERE City__c = :comune ORDER BY Month__c ASC LIMIT 1];
        return terms;
    }

}
