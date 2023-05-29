@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_QR_SlaTracking {

    public static List<SlaAdministration__c> getSlaAdminList(List<Id> adminRuleIds){
        return [ 
            SELECT Id, CaseField__c, OrderField__c, Cluster__c, CompanyOwner__c, EndDate__c, StartDate__c,
                Description__c, EndCasePhase__c, StartCasePhase__c, Range__c, Name, Process__c,
                RecordType.DeveloperName, Commodity__c, SalesCompany__c, CustomerType__c, RangeType__c, Type__c, ActivityType__c,
                StartOrderPhase__c, EndOrderPhase__c
            FROM SlaAdministration__c
            WHERE Id IN :adminRuleIds
            AND RangeType__c != null AND Range__c != null
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<TechnicalHolidaysCalendar__c> getHolidaysList(){
        return [
            SELECT HolidayDate__c, Year__c
            FROM TechnicalHolidaysCalendar__c
            WITH SECURITY_ENFORCED
        ];
    }

}