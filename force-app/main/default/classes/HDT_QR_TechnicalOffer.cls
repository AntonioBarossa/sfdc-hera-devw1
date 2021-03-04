public inherited sharing class HDT_QR_TechnicalOffer {

    public static List<TechnicalOffer__c> queryTechnicalOfferByProductId(String productId, List<TechnicalOffer__c> tecOffList){
        tecOffList = new List<TechnicalOffer__c>();
        tecOffList = [
            SELECT Id
            FROM TechnicalOffer__c
            WHERE Product__c =: productId
            WITH SECURITY_ENFORCED
            LIMIT 2
        ];
        return tecOffList;
    }

}