public inherited sharing class HDT_QR_IndemnityConfirmation {
    
    public List<Case> getOtherIndemnityCases(String recordId, String accountId, String servicePointId, String firstLevel, String secondLevel){

        return [SELECT Id,
        CreatedDate
        FROM Case
        WHERE AccountId = :accountId
        AND ServicePoint__c = :servicePointId
        AND FirstLevelComplaintClassification__c = :firstLevel
        AND SecondLevelComplaintClassification__c = :secondLevel
        AND IndemnityConfirmed__c = true
        WITH SECURITY_ENFORCED];


    }


}
