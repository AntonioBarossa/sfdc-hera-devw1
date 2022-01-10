public inherited sharing class HDT_QR_IndemnityConfirmation {

    private String indemnityCluster = 'Indennizzi';
    private Date lastYear = System.today() - 365; 
    
    public List<Case> getOtherIndemnityCases(String recordId, String accountId, String servicePointId, String firstLevel, String secondLevel){

        return [SELECT Id,
        CreatedDate
        FROM Case
        WHERE
        Cluster__c = :this.indemnityCluster
        AND Parent.AccountId = :accountId
        AND Parent.ServicePoint__c = :servicePointId
        AND Parent.FirstLevelComplaintClassification__c = :firstLevel
        AND Parent.SecondLevelComplaintClassification__c = :secondLevel
        AND Parent.IndemnityConfirmed__c = true
        AND CreatedDate > :this.lastYear
        WITH SECURITY_ENFORCED];


    }


}
