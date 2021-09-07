public inherited sharing class HDT_QR_ProductAssociation {
    
    public static Integer getNonConfiguredProduct2(String whereCondition){
        String queryString = '';
        queryString += 'SELECT count() ';
        queryString += 'FROM Product2';
        queryString += whereCondition;
        return Database.countQuery(queryString);
    }

    public static List<Product2> getNonConfiguredProduct2(List<Product2> prodList, String whereCondition){
        prodList = new List<Product2>();

        String queryString = '';
        queryString += 'SELECT DescriptionSAP__c, ProductCode, Version__c, Name, Family ';
        queryString += 'FROM Product2';
        queryString += whereCondition;

        System.debug('>>> queryString: ' + queryString);

        prodList = Database.query(queryString);

        return prodList;
    }

}