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

    public static List<TechnicalOffer__c> queryTechnicalOffer(List<TechnicalOffer__c> tecOffList, String productId, String technicalOfferId){
        tecOffList = new List<TechnicalOffer__c>();
        tecOffList = [
            SELECT Id
            FROM TechnicalOffer__c
            WHERE Id =: technicalOfferId AND Product__c = :productId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return tecOffList;
    }

    public static TechnicalOffer__c queryTechnicalOfferRecordWithChild(TechnicalOffer__c techOff, Id recId){
        techOff = [
            SELECT Id, Name, RateCategory__r.Name, (
                    SELECT Id,RowId__c,Type__c,Operand__c, Definition__c, M__c, V__c,TechnicalOffer__c,PriceCodeValue__c,StringValue__c,
                           FareType__c,FareTypeValue__c,InfoGroup__c,InfoGroupValue__c,NumericValue__c,Flag__c,PriceCode__c
                    FROM RigheOffertaTecnica__r ORDER BY RowId__c
                )
            FROM TechnicalOffer__c
            WHERE Id =: recId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return techOff;
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

    public static List<RateTemplate__c> getRateByName(List<RateTemplate__c> rateList, String rateName){
        rateList = new List<RateTemplate__c>();
        rateList = [
            SELECT Id
            FROM RateTemplate__c
            WHERE Name = :rateName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return rateList;
    }

    public static List<OperandTemplate__c> getOperandTemplate(List<OperandTemplate__c> operands, String template){
        operands = new List<OperandTemplate__c>();
        operands = [
            SELECT Id, Operands__c, ContractTemplate__c, Typology__c, UnitPrice__c, Definition__c
            FROM OperandTemplate__c
            WHERE ContractTemplate__c =: template//product.Template__c
            WITH SECURITY_ENFORCED
        ];
        return operands;
    }

    public static List<Product2> getProductById(List<Product2> prodList, String productId){
        prodList = new List<Product2>();
        prodList = [
            SELECT Id, Name, ProductCode, Version__c
            FROM Product2
            WHERE Id =: productId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return prodList;
    }

    public static StaticResource getStaticResourceByName(String name){
        return [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :name
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

}