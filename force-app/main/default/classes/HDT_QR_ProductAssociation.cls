public inherited sharing class HDT_QR_ProductAssociation {
    
    public static Integer getCountOfNonConfiguredProduct2(String queryString){
    
        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        String selectQuery = '';

        if(objRes.isAccessible()){
            selectQuery = 'SELECT count() ' + queryString;
        }

        return Database.countQuery(selectQuery);
    }

    public static List<Product2> getIdsNonConfiguredProduct2(List<Product2> prodList, String queryString){
        prodList = new List<Product2>();

        SObjectType objtype = Schema.getGlobalDescribe().get('Product2');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
        String selectQuery = '';

        if(objRes.isAccessible()){
            selectQuery = 'SELECT Id, DescriptionSAP__c, ProductCode, Version__c, Name, Family ' + queryString;
            System.debug('>>> queryString: ' + selectQuery);

            prodList = Database.query(selectQuery);
        }

        return prodList;
    }

    //public static SBQQ__ProductOption__c getProductOptionRecordById(Id productOptionId){
    //    
    //    SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ProductOption__c');
    //    Schema.DescribeSObjectResult objRes = objtype.getDescribe();
    //    String selectQuery = '';
//
    //    if(objRes.isAccessible()){
//
    //        return [
    //            SELECT Id, SBQQ__Number__c,SBQQ__OptionalSKU__c
    //            FROM SBQQ__ProductOption__c
    //            WHERE Id = :productOptionId
    //        ];
    //    } else {
    //        return null;
    //    }
    //}

}