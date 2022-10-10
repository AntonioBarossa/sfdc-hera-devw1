/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 08-06-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class HDT_LC_ActiveRepentant {

    public with sharing class HDT_WRP_Data{
        @AuraEnabled public List<TermsAdministration__c> termsAdministration {get;set;}
        @AuraEnabled public List<TermTable__c> termsTable {get;set;}
        @AuraEnabled public List<CityTechnicalData__c> cityData {get;set;}

        HDT_WRP_Data(){return;}
        public HDT_WRP_Data(List<TermsAdministration__c> termsAdministration, List<TermTable__c> termsTable, List<CityTechnicalData__c> cityData){
            this.termsAdministration=termsAdministration;
            this.termsTable=termsTable;
            this.cityData=cityData;
        }
    }

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
    public Date dateDecorrenza {get;set;}

    @AuraEnabled
    public Date dateDichiarazione {get;set;}

    @AuraEnabled
    public static List<TermTable__c> getPeriods(String comune, String searchKey){
        List<TermTable__c> periods =  [SELECT Id, CriteriaX__c, EffectiveDate__c, DayX__c, CriteriaY__c, DayY__c, PopupY__c, PopupZ__c 
                                            FROM TermTable__c WHERE City__c = :comune AND (Subtype__c =:searchKey OR Type__c=:searchKey) WITH SECURITY_ENFORCED LIMIT 1];
        return periods;
    }

    @AuraEnabled
    public static List<TermsAdministration__c> getTerms(String comune){
        List<TermsAdministration__c> terms =  [SELECT Id, City__c, Day__c, Month__c FROM TermsAdministration__c WHERE City__c = :comune WITH SECURITY_ENFORCED ORDER BY Month__c ASC ];
        return terms;
    }

    public static List<CityTechnicalData__c> getCityTecData(String comune){
        List<CityTechnicalData__c> cityData =  [SELECT Id, TARIManagingStartDate__c, TARIManagingEndDate__c, CityNotManagedAlert__c, CutOverEndDate__c, TARIManaged__c FROM CityTechnicalData__c WHERE CadastralCity__c = :comune WITH SECURITY_ENFORCED LIMIT 1];
        return cityData;
    }

    @AuraEnabled
    public static HDT_WRP_Data getTables(String comune, String sottotipo){
        //return new HDT_WRP_Data(getTerms(comune), getPeriods(comune, sottotipo), getCityTecData(comune));
        return new HDT_WRP_Data(null, getPeriods(comune, sottotipo), getCityTecData(comune));
    }

}
