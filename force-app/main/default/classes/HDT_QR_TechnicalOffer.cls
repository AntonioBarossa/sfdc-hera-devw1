public inherited sharing class HDT_QR_TechnicalOffer {

    public static List<TechnicalOffer__c> getOfferById(List<TechnicalOffer__c> tecOffList, String technicalOfferId){
        tecOffList = new List<TechnicalOffer__c>();
        tecOffList = [
            SELECT Id, OfferCode__c
            FROM TechnicalOffer__c
            WHERE Id =: technicalOfferId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return tecOffList;
    }

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

    public static TechnicalOffer__c queryTechnicalOfferForWebService(TechnicalOffer__c techOff, Id recId){
        techOff = [
            SELECT Id, Name, Product__r.ProductCode, Product__r.DescriptionSAP__c, RateCategory__r.Name, Market__c, ProcessType__c, PlacetOffer__c, ServiceProduct__c, StepAllowed__c, StartDate__c, EndDate__c,
                   ContractId__c, NumberTimeExtension__c, UnitTimeExtension__c, CancellationAllowed__c, NumberDaysMonthsYears__c,
                   UnitTerminationTime__c, RecessAdmitted__c, NumberOfTimeUnits__c, UnitOfTimeMeasurement__c, AdmittingProfileModification__c,
                   OfferToBeModified__c,Version__c,
                (
                    SELECT Id,RowId__c,Type__c,Operand__c, Definition__c, M__c, V__c,S__c, G__c,TechnicalOffer__c,PriceCodeValue__c,DiscountCodeValue__c, DiscountCode__c,StringValue__c,
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

    public static TechnicalOffer__c queryTechnicalOfferRecordWithChild(TechnicalOffer__c techOff, Id recId){
        techOff = [
            SELECT Id, Name, RateCategory__r.Name, Product__r.Status__c, (
                    SELECT Id,RowId__c,Type__c,Operand__c, Definition__c, M__c, V__c,S__c, G__c, TechnicalOffer__c,PriceCodeValue__c,DiscountCodeValue__c, DiscountCode__c,StringValue__c,
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

    public static TechnicalOffer__c queryTechnicalOfferRecordById(TechnicalOffer__c techOff, String recId){
        techOff = [
            SELECT Id, Market__c, ProcessType__c, PlacetOffer__c, ServiceProduct__c, StepAllowed__c, StartDate__c, EndDate__c,
                   ContractId__c, NumberTimeExtension__c, UnitTimeExtension__c, CancellationAllowed__c, NumberDaysMonthsYears__c,
                   UnitTerminationTime__c, RecessAdmitted__c, NumberOfTimeUnits__c, UnitOfTimeMeasurement__c, AdmittingProfileModification__c,
                   OfferToBeModified__c
            FROM TechnicalOffer__c
            WHERE Id =: recId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return techOff;
    }

    public static List<RateTemplate__c> getRateList(String queryTerm) {

        String myQuery = '';
        myQuery += 'SELECT Id, Name, ContractTemplate__c, ServiceProduct__c ';
        myQuery += 'FROM RateTemplate__c ';
        myQuery += 'WHERE Visibile__c = true';

        if(!String.isEmpty(queryTerm)){
            myQuery += ' AND Name LIKE \'%' + queryTerm + '%\'';
        }

        myQuery += ' WITH SECURITY_ENFORCED';

        SObjectType objtype = Schema.getGlobalDescribe().get('RateTemplate__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        List<RateTemplate__c> rateTempList;
        if(objRes.isAccessible()){
            rateTempList = database.query(myQuery);
        } else {
            rateTempList = new List<RateTemplate__c>();
        }

        return rateTempList;
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

    public static List<Product2> getProduct2ByCode(List<Product2> prodList, String productCode, Id productId){
        prodList = new List<Product2>();
        prodList = [
            SELECT Id, (SELECT Id FROM Technical_Offer__r LIMIT 1)
            FROM Product2
            WHERE Id !=: productId AND ProductCode = :productCode
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return prodList;
    }

    public static List<sObject> getRecordsList(List<sObject> allValues, String objectApiName, String fieldsApiName, String whereCond){
        allValues = new List<sObject>();
        String myQuery = 'SELECT Id,';
        myQuery += fieldsApiName;
        myQuery += ' FROM ' + objectApiName;
        
        if(!String.isEmpty(whereCond)){
            myQuery += whereCond;
        }

        myQuery += ' LIMIT 100';

        SObjectType objtype = Schema.getGlobalDescribe().get(objectApiName);
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isAccessible()){
            allValues = database.query(myQuery);
        }

        return allValues;
    }

    public static List<Info1GroupList__c> getTariffDetails(List<Info1GroupList__c> infoOneGroupList, String rate){
        infoOneGroupList = new List<Info1GroupList__c>();
        infoOneGroupList = [
            SELECT Id, DetTariffa__c, FilterTypeCategory__c
            FROM Info1GroupList__c
            WHERE FilterTypeCategory__c = :rate
            WITH SECURITY_ENFORCED
        ];
        return infoOneGroupList;
    }

    public static List<sObject> getInfo2GroupList(List<sObject> infoTwoGroupList, String whereCond){
        infoTwoGroupList = new List<sObject>();
        String myQuery = 'SELECT Id, ValueDescription__c, DetRate__c, PossibleValue__c ';
        myQuery += 'FROM Info2GroupList__c ';

        if(!String.isEmpty(whereCond)){
            myQuery += whereCond;
        }

        myQuery += ' LIMIT 100';

        SObjectType objtype = Schema.getGlobalDescribe().get('Info2GroupList__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isAccessible()){
            infoTwoGroupList = database.query(myQuery);
        }

        return infoTwoGroupList;
    }

    //public static List<Info2GroupList__c> getInfo2GroupList(List<Info2GroupList__c> infoTwoGroupList, List<String> tariffList){
    //    infoTwoGroupList = new List<Info2GroupList__c>();
    //    infoTwoGroupList = [
    //        SELECT Id, ValueDescription__c, DetRate__c, PossibleValue__c
    //        FROM Info2GroupList__c
    //        WHERE DetRate__c IN :tariffList
    //        WITH SECURITY_ENFORCED
    //    ];
    //    return infoTwoGroupList;
    //}

}