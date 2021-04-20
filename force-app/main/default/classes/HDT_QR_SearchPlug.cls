public inherited sharing class HDT_QR_SearchPlug {

    public static List<Product2> getEligibilitiesCriteriaFromProduct(List<Product2> prodWithoutCriteria, List<String> familyList, String status){
        prodWithoutCriteria = new List<Product2>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            prodWithoutCriteria = [
                SELECT Id, (SELECT Id FROM EligibilitiesCriteria__r)
                FROM Product2
                WHERE Status__c = :status AND IsActive = true AND Family IN :familyList
                WITH SECURITY_ENFORCED
            ];

        }

        return prodWithoutCriteria;
    }

    public static List<EligibleMunicipality__c> findEligibleMunicipality(Set<Id> idToFilterByMunicipalities, List<String> familyList, String supplyCity){

        String searchquery = '';
        List<List<SObject>> searchList;
        SObjectType objtype = Schema.getGlobalDescribe().get('EligibleMunicipality__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            searchquery += 'FIND \'' + supplyCity + '\' IN ALL FIELDS';
            searchquery += ' RETURNING EligibleMunicipality__c(';
            searchquery += 'EligibilityCriteria__r.Product__c';
            searchquery += ' WHERE';
            searchquery += ' EligibilityCriteria__r.Product__r.Status__c = \'Vendibile\' AND';
            searchquery += ' EligibilityCriteria__r.Product__r.IsActive = true AND';
            searchquery += ' EligibilityCriteria__r.Product__r.Family IN :familyList AND';
            searchquery += ' EligibilityCriteria__c IN: idToFilterByMunicipalities)';

            searchList = search.query(searchquery);

        }

        return ((List<EligibleMunicipality__c>)searchlist[0]);
    }

    public static SBQQ__Quote__c selectQuoteFromId(Id currentId, SBQQ__Quote__c myQuote){

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__Quote__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            myQuote = [
                SELECT Id, SBQQ__PricebookId__c, SBQQ__PriceBook__c, SupplyCity__c,
                       Market__c, Channel__c, ClientMarker__c, CategoryTypeClient__c,
                       CompanyOwner__c, ClientAge__c, ConsumptionRangeEE__c, ConsumptionRangeGAS__c, PowerRange__c,
                       ResidentDeliveryAddress__c, FriendCode__c, NewClient__c, SBQQ__Account__c, UseCategory__c, EquipmenType__c
                FROM SBQQ__Quote__c
                WHERE Id = :currentId
                WITH SECURITY_ENFORCED
            ];

        }

        return myQuote;
    }

    public static List<EligibilityCriteria__c> selectEligibleCriteria(List<EligibilityCriteria__c> eligibilityCriteriaList, List<String> familyList, SBQQ__Quote__c quote){
        eligibilityCriteriaList = new List<EligibilityCriteria__c>();

        SObjectType objtype = Schema.getGlobalDescribe().get('EligibilityCriteria__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            eligibilityCriteriaList = [
                SELECT Product__c, EligibleForAllCities__c,
                       ClientAgeMin__c, ClientAgeMax__c,
                       ConsumptionRangeEEmin__c, ConsumptionRangeEEmax__c,
                       ConsumptionRangeGASmin__c, ConsumptionRangeGASmax__c,
                       PowerRangeMin__c, PowerRangeMax__c

                FROM EligibilityCriteria__c
                WHERE Product__r.Status__c = 'Vendibile' AND Product__r.IsActive = true AND Product__r.Family IN :familyList AND

                    (OriginMarket__c includes (:quote.Market__c) OR OriginMarket__c = null) AND
                    (Channel__c includes (:quote.Channel__c) OR Channel__c = null) AND
                    (ClientMarker__c includes (:quote.ClientMarker__c) OR ClientMarker__c = null) AND
                    (CategoryTypeClient__c includes (:quote.CategoryTypeClient__c) OR CategoryTypeClient__c = null) AND
                    (CompanyOwner__c includes (:quote.CategoryTypeClient__c) OR CategoryTypeClient__c = null) AND
                    //quote.CampaignCode__c ???
                    (PromoCode__c = :quote.FriendCode__c OR PromoCode__c = null) AND
                    (Agency__c = :quote.SBQQ__Account__c OR Agency__c = null) AND
                    (UseCategory__c = :quote.UseCategory__c OR UseCategory__c = null) AND
                    (EquipmenType__c = :quote.EquipmenType__c OR EquipmenType__c = null)

            ];
            //Multipicklist
            //queryString += '(OriginMarket__c includes (\'' + quote.Market__c + '\') OR OriginMarket__c = null) AND ';
            //queryString += '(Channel__c includes (\'' + quote.Channel__c + '\') OR Channel__c = null) AND ';
            //queryString += '(ClientMarker__c includes (\'' + quote.ClientMarker__c + '\') OR ClientMarker__c = null) AND ';
            //queryString += '(CategoryTypeClient__c includes (\'' + quote.CategoryTypeClient__c + '\') OR CategoryTypeClient__c = null) AND ';
            //queryString += '(CompanyOwner__c includes (\'' + quote.CompanyOwner__c + '\') OR CompanyOwner__c = null)';
            //eligibilityCriteriaList = Database.query(queryString);
        }

        return eligibilityCriteriaList;

    }

}