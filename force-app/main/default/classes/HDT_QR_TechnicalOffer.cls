public inherited sharing class HDT_QR_TechnicalOffer {

    public static List<TechnicalOffer__c> queryTechnicalOfferByProductId(String productId, List<TechnicalOffer__c> tecOffList){
        tecOffList = new List<TechnicalOffer__c>();
        tecOffList = [
            SELECT Id, Name, Template__c, RateCategory__r.Name
            FROM TechnicalOffer__c
            WHERE Product__c =: productId
            WITH SECURITY_ENFORCED
            LIMIT 2
        ];
        return tecOffList;
    }

    public static List<RateTemplate__c> getRateList(String queryTerm) {

        String myQuery = 'SELECT Id, Name, ContractTemplate__c FROM RateTemplate__c';

        if(!String.isEmpty(queryTerm)){
            myQuery += ' WHERE Name LIKE \'%' + queryTerm + '%\'';
        }

        myQuery += ' WITH SECURITY_ENFORCED';

        List<RateTemplate__c> lookUpList = database.query(myQuery);

        return lookUpList;
    }

}