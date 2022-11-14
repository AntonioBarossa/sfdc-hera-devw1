public inherited sharing class HDT_QR_IndemnityConfirmation {

    private String indemnityCluster = 'Indennizzi';
    private Date lastYear = System.today() - 365; 
    
    /* This method is called when the source is NOT a container */
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
        AND CreatedDate = LAST_N_DAYS:365
        WITH SECURITY_ENFORCED];
    }
    /** This method is called when the source is container */
    public List<Case> getOtherIndemnityCases(String recordId, String accountId, Set<String> servicePointSet, Set<String> firstLevelSet, Set<String> secondLevelSet){
        return [SELECT Id,
        Parent.ServicePoint__c,
        Parent.FirstLevelComplaintClassification__c,
        Parent.SecondLevelComplaintClassification__c,
        CreatedDate
        FROM Case
        WHERE
        Cluster__c = :this.indemnityCluster
        AND Parent.AccountId = :accountId
        AND Parent.ServicePoint__c IN :servicePointSet
        AND Parent.FirstLevelComplaintClassification__c IN :firstLevelSet
        AND Parent.SecondLevelComplaintClassification__c IN :secondLevelSet
        AND Parent.IndemnityConfirmed__c = true
        AND CreatedDate = LAST_N_DAYS:365
        WITH SECURITY_ENFORCED];
    }


}