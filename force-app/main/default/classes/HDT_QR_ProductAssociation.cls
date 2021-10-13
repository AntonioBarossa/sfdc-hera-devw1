public inherited sharing class HDT_QR_ProductAssociation {
    
    public static Integer getCountOfNonConfiguredProduct2(String queryString){
    
        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        String selectQuery = '';

        if(objRes.isAccessible()){
            selectQuery = 'SELECT count() ' + queryString;
        }
        System.debug(logginglevel.DEBUG, '>>> queryString: ' + selectQuery);
        return Database.countQuery(selectQuery);
    }

    public static List<Product2> getIdsNonConfiguredProduct2(List<Product2> prodList, String queryString){
        prodList = new List<Product2>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        String selectQuery = '';

        if(objRes.isAccessible()){
            selectQuery = 'SELECT Id, DescriptionSAP__c, ProductCode, Version__c, Name, Family, CategoryFamily__c, Service__c, Status__c ' + queryString;
            System.debug(logginglevel.DEBUG, '>>> queryString: ' + selectQuery);

            prodList = Database.query(selectQuery);
        }

        return prodList;
    }

    public static List<SBQQ__ProductOption__c> getProductOptionByOptionalSkuAndConfiguredSku(List<SBQQ__ProductOption__c> productOptionList, String optionalSku, List<String> configuredSkuList){

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ProductOption__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        productOptionList = new List<SBQQ__ProductOption__c>();

        if(objRes.isAccessible()){
            productOptionList = [
                SELECT Id
                FROM SBQQ__ProductOption__c
                WHERE SBQQ__OptionalSKU__c = :optionalSku
                AND SBQQ__ConfiguredSKU__c IN :configuredSkuList
            ];
        }

        return productOptionList;

    }

    public static AggregateResult[] getCountFromProductOption(List<String> recordIdList){

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ProductOption__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        AggregateResult[] results;

        if(objRes.isAccessible()){
            results = [
                SELECT SBQQ__ConfiguredSKU__c, count(Id)
                FROM SBQQ__ProductOption__c
                WHERE SBQQ__ConfiguredSKU__c IN :recordIdList
                WITH SECURITY_ENFORCED
                GROUP BY SBQQ__ConfiguredSKU__c
            ];
        }
        return results;
    }

    public static Id getCustomNotificationTypeId(){
        return [SELECT Id FROM CUstomNotificationType LIMIT 1].Id;
    }

    public static List<SBQQ__ProductFeature__c> productFeatureListByFamily(List<SBQQ__ProductFeature__c> productFeatureList, List<String> configSkuList, String familyName){
        productFeatureList = new List<SBQQ__ProductFeature__c>();

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ProductFeature__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){
            productFeatureList = [
                SELECT Id, Name, SBQQ__ConfiguredSKU__c
                FROM SBQQ__ProductFeature__c
                WHERE SBQQ__ConfiguredSKU__c IN :configSkuList
                AND Name = :familyName
                WITH SECURITY_ENFORCED
            ];
        }
        return productFeatureList;
    }

    public static List<Product2> getProductOption2recordBySkuId(List<Product2> prod2list, Id confSkuId){
        prod2list = new List<Product2>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){
            prod2list = [
                SELECT Id, Family
                FROM Product2
                WHERE Id = :confSkuId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        }
        return prod2list;
    }

    public static List<AsyncApexJob> getJobStatus(List<String> apexJobClass){
        List<AsyncApexJob> jobList = new List<AsyncApexJob>();
        jobList = [
            SELECT ExtendedStatus, ApexClass.name, MethodName, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
            FROM AsyncApexJob
            WHERE CompletedDate = today
            AND ApexClass.name IN :apexJobClass
            AND Status NOT IN ('Aborted', 'Completed', 'Failed')
        ];
        return jobList;
    }

    public static List<SBQQ__ConfigurationRule__c> getConfigurationRuleByProductIdAndRuleId(List<SBQQ__ConfigurationRule__c> configurationRuleList, String ruleId, List<String> prodcutIdList){

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ConfigurationRule__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        configurationRuleList = new List<SBQQ__ConfigurationRule__c>();

        if(objRes.isAccessible()){
            configurationRuleList = [
                SELECT Id
                FROM SBQQ__ConfigurationRule__c
                WHERE SBQQ__ProductRule__c = :ruleId
                AND SBQQ__Product__c IN :prodcutIdList
            ];
        }

        return configurationRuleList;

    }

    public static List<GroupMember> getGroupMembers(List<GroupMember> groupMembers, Id currentUserId, String groupDeveloperName){
        groupMembers = new List<GroupMember>();

        SObjectType objtype = Schema.getGlobalDescribe().get('GroupMember');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();

        if(objRes.isAccessible()){

            groupMembers = [
                SELECT Id
                FROM GroupMember
                WHERE Group.DeveloperName = :groupDeveloperName
                AND UserOrGroupId = :currentUserId
            ];
        }

        return groupMembers;

    }

}