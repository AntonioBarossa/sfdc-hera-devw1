public without sharing class HDT_QR_SearchPlug {

    public static List<Product2> getAllAvailableProducts(List<Product2> prodWithoutCriteria, List<String> familyList, List<String> statusList){
        prodWithoutCriteria = new List<Product2>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            prodWithoutCriteria = [
                SELECT Id
                FROM Product2
                WHERE Status__c IN :statusList
                AND IsActive = true
                AND Family IN :familyList
                AND NoOrderable__c = false
                AND NoSellable__c = false
                //AND (NOT ProductCode LIKE :Label.HDT_CPQ_TemplateProductCode)
                WITH SECURITY_ENFORCED
            ];

        }

        return prodWithoutCriteria;
    }

    public static List<Product2> getEligibilitiesCriteriaFromProduct(List<Product2> prodWithoutCriteria, List<String> statusList, List<String> familyList){
        prodWithoutCriteria = new List<Product2>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            prodWithoutCriteria = [
                SELECT Id, (SELECT Id FROM EligibilitiesCriteria__r)
                FROM Product2
                WHERE Status__c IN :statusList
                AND IsActive = true
                AND Family IN :familyList
                AND NoOrderable__c = false
                AND NoSellable__c = false
                //AND (NOT ProductCode LIKE :Label.HDT_CPQ_TemplateProductCode)
                WITH SECURITY_ENFORCED
            ];

        }

        return prodWithoutCriteria;
    }

    public static List<EligibleMunicipality__c> findEligibleMunicipality(Set<Id> idToFilterByMunicipalities, List<String> statusList, List<String> familyList, String supplyCity){

        String searchquery = '';
        List<List<SObject>> searchList;
        SObjectType objtype = Schema.getGlobalDescribe().get('EligibleMunicipality__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            searchquery += 'FIND \'' + supplyCity + '\' IN ALL FIELDS';
            searchquery += ' RETURNING EligibleMunicipality__c(';
            searchquery += 'EligibilityCriteria__r.Product__c';
            searchquery += ' WHERE';
            //searchquery += ' EligibilityCriteria__r.Product__r.Status__c = \'Vendibile\' AND';
            searchquery += ' EligibilityCriteria__r.Product__r.Status__c IN :statusList AND';
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
                SELECT Id, ListPriceName__c, SBQQ__PricebookId__c, SBQQ__PriceBook__c, SupplyCity__c, CampaignName__c, CampaignEleggibilityGroup__c,
                       Market__c, Channel__c, CustomerMarking__c, CategoryTypeClient__c, SuperUser__c,
                       CompanyOwner__c, ClientAge__c, ConsumptionRangeEE__c, ConsumptionRangeGAS__c, PowerFlow__c,
                       ResidentDeliveryAddress__c, FriendCode__c, NewClient__c, Agency__c, UseCategory__c, MeterType__c, LoginGroup__c,
                       // W2
                       AtoReference__c, ImplantType__c
                FROM SBQQ__Quote__c
                WHERE Id = :currentId
                WITH SECURITY_ENFORCED
            ];

        }

        return myQuote;
    }

    public static List<EligibilityCriteria__c> selectEligibleCriteria(List<EligibilityCriteria__c> eligibilityCriteriaList, List<String> statusList, List<String> familyList, SBQQ__Quote__c quote){
        eligibilityCriteriaList = new List<EligibilityCriteria__c>();

        SObjectType objtype = Schema.getGlobalDescribe().get('EligibilityCriteria__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            eligibilityCriteriaList = [
                SELECT Product__c, EligibleForAllCities__c,
                       ClientAgeMin__c, ClientAgeMax__c, LoginGroup__r.NameGroup__c,
                       ConsumptionRangeEEmin__c, ConsumptionRangeEEmax__c,
                       ConsumptionRangeGASmin__c, ConsumptionRangeGASmax__c,
                       PowerRangeMin__c, PowerRangeMax__c, ResidentDeliveryAddress__c,
                       NewClient__c, Campaign__c, product__r.productcode

                FROM EligibilityCriteria__c
                WHERE Product__r.Status__c IN :statusList AND Product__r.IsActive = true AND Product__r.Family IN :familyList AND Product__r.NoOrderable__c = false AND Product__r.NoSellable__c = false AND

                    (
                        (OriginMarketOperator__c = 'excludesValues' AND OriginMarket__c excludes (:quote.Market__c)) OR
                        (OriginMarketOperator__c = 'includesValues' AND OriginMarket__c includes (:quote.Market__c)) OR
                        (OriginMarketOperator__c = 'includesAll')
                    ) AND 

                    (
                        (ChannelOperator__c = 'excludesValues' AND Channel__c excludes (:quote.Channel__c)) OR
                        (ChannelOperator__c = 'includesValues' AND Channel__c includes (:quote.Channel__c)) OR
                        (ChannelOperator__c = 'includesAll')
                    ) AND 
                    
                    (
                        (ClientMarkerOperator__c = 'excludesValues' AND ClientMarker__c excludes (:quote.CustomerMarking__c)) OR
                        (ClientMarkerOperator__c = 'includesValues' AND ClientMarker__c includes (:quote.CustomerMarking__c)) OR
                        (ClientMarkerOperator__c = 'includesAll')
                    ) AND
                    
                    (
                        (CategoryTypeClientOperator__c = 'excludesValues' AND CategoryTypeClient__c excludes (:quote.CategoryTypeClient__c)) OR
                        (CategoryTypeClientOperator__c = 'includesValues' AND CategoryTypeClient__c includes (:quote.CategoryTypeClient__c)) OR
                        (CategoryTypeClientOperator__c = 'includesAll')
                    ) AND 
                    
                    (
                        (CompanyOwnerOperator__c = 'excludesValues' AND CompanyOwner__c excludes (:quote.CompanyOwner__c)) OR
                        (CompanyOwnerOperator__c = 'includesValues' AND CompanyOwner__c includes (:quote.CompanyOwner__c)) OR
                        (CompanyOwnerOperator__c = 'includesAll')
                    ) AND
                    (
                        (AtoReferenceOperator__c = 'excludesValues' AND AtoReference__c excludes (:quote.AtoReference__c)) OR
                        (AtoReferenceOperator__c = 'includesValues' AND AtoReference__c includes (:quote.AtoReference__c)) OR
                        (AtoReferenceOperator__c = 'includesAll')
                    ) AND
                    (
                        (ImplantTypeOperator__c = 'excludesValues' AND ImplantType__c excludes (:quote.ImplantType__c)) OR
                        (ImplantTypeOperator__c = 'includesValues' AND ImplantType__c includes (:quote.ImplantType__c)) OR
                        (ImplantTypeOperator__c = 'includesAll')
                    ) AND
                    (Campaign__c = :quote.CampaignEleggibilityGroup__c OR Campaign__c = null) AND
                    (CampaignName__c = :quote.CampaignName__c OR CampaignName__c = null) AND
                    (PromoCode__c = :quote.FriendCode__c OR PromoCode__c = null) AND
                    (Agency__r.AgencyCode__c = :quote.Agency__c OR Agency__c = null) AND
                    (UseCategory__c includes (:quote.UseCategory__c) OR UseCategory__c = null) AND
                    (EquipmenType__c = :quote.MeterType__c OR EquipmenType__c = null)
                    //AND (NOT Product__r.ProductCode LIKE :Label.HDT_CPQ_TemplateProductCode)
            ];

        }

        return eligibilityCriteriaList;

    }

    public static List<LoginGroupItem__c> getLoginGroupItemByUser(Id currentUserId){
        return [
            SELECT LoginGroup__c
            FROM LoginGroupItem__c
            WHERE Login__c = :currentUserId
            WITH SECURITY_ENFORCED
        ];
    }

    //public static Integer getUserForLoginGroup(Id currentUserId, Id loginGroupId){
    //    return [
    //        SELECT count()
    //        FROM LoginGroupItem__c
    //        WHERE LoginGroup__c = :loginGroupId AND Login__c = :currentUserId
    //        WITH SECURITY_ENFORCED
    //    ];
    //}

    public static List<PermissionSetAssignment> getUserPermissionSets(List<PermissionSetAssignment> assignmentList, Id currentUserId, String permissionToCheck){
        assignmentList = new List<PermissionSetAssignment>();
        assignmentList = [
            SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = :permissionToCheck AND AssigneeId = :currentUserId
        ];
        return assignmentList;
    }

}