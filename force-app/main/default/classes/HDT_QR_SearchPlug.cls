public inherited sharing class HDT_QR_SearchPlug {

    public static List<Product2> getEligibilitiesCriteriaFromProduct(List<Product2> prodWithoutCriteria, List<String> familyList, String status){
        prodWithoutCriteria = new List<Product2>();
        prodWithoutCriteria = [
            SELECT Id, (SELECT Id FROM EligibilitiesCriteria__r)
            FROM Product2
            WHERE Status__c = :status AND IsActive = true AND Family IN :familyList
            WITH SECURITY_ENFORCED
        ];
        return prodWithoutCriteria;
    }

    

}