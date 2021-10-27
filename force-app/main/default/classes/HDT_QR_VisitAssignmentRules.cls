/**
* @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
* @date 5/02/2021
* @description HDT_QR_VisitAssignmentRules – Contains query for VisitAssignmentRules
* @history Laureta Demishaj – 10/06/2021 – Created class
*/

public with sharing class HDT_QR_VisitAssignmentRules {

    public static VisitAssignmentRules__c getRecordById(String Id) {
        return [
            SELECT 
            Id,
            Name,
            cap__c,
            Category__c,
            Consumption__c
            FROM VisitAssignmentRules__c
            where Id = :Id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    public static List<VisitAssignmentRules__c> getAssignmentConfigurations(String zipCode, String category, String consumption){
        return[
        SELECT
        Id,
        cap__c,
        Category__c,
        Consumption__c,
        Name
        FROM VisitAssignmentRules__c
        WHERE cap__c = :zipCode AND Category__c = :category AND Consumption__c = :consumption
        WITH SECURITY_ENFORCED
        ];
    }

}