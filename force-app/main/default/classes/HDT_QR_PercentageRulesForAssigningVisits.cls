/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 5/02/2021
* @description HDT_QR_Campaign – Contains query for Campaign
* @history Sabina Levonja – 5/02/2021 – Created class
*/

public with sharing class HDT_QR_PercentageRulesForAssigningVisits {

    public static PercentageRulesForAssigningVisits__c getRecordById(String Id) {
        return [
            SELECT 
            Id,
            Name,
            agency__c,
            PercentageOfAssignment__c,
            VisitAssignmentRules__c
           
            FROM PercentageRulesForAssigningVisits__c
            where Id = :Id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public static List<PercentageRulesForAssigningVisits__c> getRecordsByVisitAssignmentRules(String Id) {
        return [
            SELECT 
            Id,
            Name,
            agency__c,
            PercentageOfAssignment__c,
            VisitAssignmentRules__c
            FROM PercentageRulesForAssigningVisits__c
            WHERE VisitAssignmentRules__c	 = :Id
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<PercentageRulesForAssigningVisits__c> getDefaultValue() {
        return [
            SELECT 
            Id,
            Name,
            agency__c,
            PercentageOfAssignment__c,
            VisitAssignmentRules__c
            FROM PercentageRulesForAssigningVisits__c
            WHERE VisitAssignmentRules__r.Name	 = 'Default'
            WITH SECURITY_ENFORCED
        ];
    }

}