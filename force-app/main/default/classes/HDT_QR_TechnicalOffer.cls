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

        String myQuery = 'SELECT Id, Name, ContractTemplate__c';
        myQuery += ' FROM RateTemplate__c';

        if(!String.isEmpty(queryTerm)){
            myQuery += ' WHERE Name LIKE \'%' + queryTerm + '%\'';
        }

        myQuery += ' WITH SECURITY_ENFORCED';

        SObjectType objtype = Schema.getGlobalDescribe().get('TechnicalOfferItem__c');
 
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        List<RateTemplate__c> lookUpList;
        if(objRes.isAccessible()){
            lookUpList = database.query(myQuery);
        } else {
            lookUpList = new List<RateTemplate__c>();
        }

        return lookUpList;
    }

}