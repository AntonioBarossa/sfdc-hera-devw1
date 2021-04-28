public inherited sharing class HDT_QR_EligibilityCriteria {

    public static List<EligibilityCriteria__c> getEligibilityCriteriaSingleRecord(List<EligibilityCriteria__c> criteria, String eligibilityId){
        criteria = new List<EligibilityCriteria__c>();
        criteria = [
            SELECT EligibleForAllCities__c
            FROM EligibilityCriteria__c
            WHERE Id = :eligibilityId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return criteria;
    }

    public static List<EligibleMunicipality__c> getEligibleMunicipalityByCriteriaId(List<EligibleMunicipality__c> muniList, String eligibilityId){
        muniList = new List<EligibleMunicipality__c>();
        muniList = [
            SELECT Id, Name, AreaCode__c, JSONCode__c
            FROM EligibleMunicipality__c
            WHERE EligibilityCriteria__c =: eligibilityId
            WITH SECURITY_ENFORCED
        ];
        return muniList;
    }

    public static StaticResource getMunicipalitiesStaticResource(){
        return [SELECT Id, Body FROM StaticResource WHERE Name = 'Municipalities' WITH SECURITY_ENFORCED LIMIT 1];
    }

    public static List<EligibilityCriteria__c> getEligibilityCriteriaByIdAndProductId(List<EligibilityCriteria__c> criteriaList, String eligibilityId, String productId){
        criteriaList = new List<EligibilityCriteria__c>();
        criteriaList = [
            SELECT Id
            FROM EligibilityCriteria__c
            WHERE Id =: eligibilityId AND Product__c = :productId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return criteriaList;
    }

    public static List<EligibilityCriteria__c> getEligibilityCriteriaByProductId(List<EligibilityCriteria__c> criteriaList, String productId){
        criteriaList = new List<EligibilityCriteria__c>();
        criteriaList = [
            SELECT Id
            FROM EligibilityCriteria__c
            WHERE Product__c = :productId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return criteriaList;
    }

    public static EligibilityCriteria__c getEligibilityCriteriaWithChild(EligibilityCriteria__c crtiteriaToClone, String recIdToClone){
        crtiteriaToClone = [
            SELECT Id, Name,
                   OriginMarket__c,CategoryTypeClient__c,LoginGroup__c,ResidentDeliveryAddress__c,CompanyOwner__c,
                   Campaign__c,PromoCode__c,Channel__c,ClientMarker__c,Login__c,NewClient__c,Agency__c,UseCategory__c,
                   EquipmenType__c,ClientAgeMin__c,ConsumptionRangeEEmin__c,ConsumptionRangeGASmin__c,PowerRangeMin__c,
                   ClientAgeMax__c,ConsumptionRangeEEmax__c,ConsumptionRangeGASmax__c,PowerRangeMax__c,EligibleForAllCities__c,
                   CampaignName__c,
                   CategoryTypeClientOperator__c,ChannelOperator__c,OriginMarketOperator__c,ClientMarkerOperator__c,CompanyOwnerOperator__c,
                   (SELECT Id, Name, AreaCode__c, JSONCode__c FROM Comuni_Eleggibili__r)
            FROM EligibilityCriteria__c
            WHERE Id =: recIdToClone
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return crtiteriaToClone;
    }

}