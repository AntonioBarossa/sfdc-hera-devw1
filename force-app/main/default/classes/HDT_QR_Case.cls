/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 10/03/2021
* @description HDT_QR_Case– Contains queries for Case
* @history Fatjola Memishaj – 10/03/2021 – Created class
*/

public inherited sharing class HDT_QR_Case {
    
    public Case getRecordById(String Id) {
        return [
            SELECT 
            Id,
            Status,
            Subject,
            Subprocess__c,
            AccountId,
            CaseNumber,
            HerokuPracticeCode__c
            FROM Case
            where Id = :Id
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
    
    public List<Case> getChageNonRegMeterByOrder(String orderId){

        return [SELECT Id
        FROM Case
        WHERE Type = 'Cambio Contatore Non Registrato'
        AND Phase__c = 'Completata'
        AND VulturePracticeReference__c = :orderId
        WITH SECURITY_ENFORCED];
        
    }

    public Case getParentCaseById(String caseId){

        return [SELECT Id,
        Type,
        Phase__c,
        DistributorName__c
        FROM Case
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
        LIMIT 1];

    }


}
