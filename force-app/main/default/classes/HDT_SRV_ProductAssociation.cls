public inherited sharing class HDT_SRV_ProductAssociation {

    public static Object getProductList(String filterString){

        System.debug('>>> filterString: ' + filterString);
        HDT_WRP_RespObj respObj = new HDT_WRP_RespObj();

        try{
            String whereCondition = generateWhereCondition(filterString);
            System.debug('>>> whereCondition: ' + whereCondition);
            respObj.success = true;
            Integer recordCounter = HDT_QR_ProductAssociation.getNonConfiguredProduct2(whereCondition);
            respObj.recordCounter = String.valueOf(recordCounter);
            System.debug('>>> recordCounter: ' + recordCounter);
            respObj.prodList = HDT_QR_ProductAssociation.getNonConfiguredProduct2(respObj.prodList, whereCondition);
        } catch (Exception ex){
            respObj.success = false;
            respObj.message = '[' + String.valueOf(ex.getLineNumber()) + '] ' + ex.getMessage();
        }

        return respObj;
    }

    public static String generateWhereCondition(String filterString){
        Product2 filterProduct = (Product2)JSON.deserialize(filterString, Product2.class);
        System.debug('>>> FILTER PRODUCT: ' + String.valueOf(filterProduct));

        String whereCondition = ' WHERE ';
        if(!String.isEmpty(filterProduct.Name)){
            whereCondition += 'Name LIKE \'%' + filterProduct.Name + '%\'';
        }

        if(!String.isEmpty(filterProduct.TypeOffer__c)){
            whereCondition += ' AND TypeOffer__c = \'' + filterProduct.TypeOffer__c + '\'';
        }

        if(!String.isEmpty(filterProduct.ProductCode)){
            whereCondition += ' AND ProductCode LIKE \'%' + filterProduct.ProductCode + '%\'';
        }

        if(!String.isEmpty(filterProduct.Family)){
            whereCondition += ' AND Family = \'' + filterProduct.Family + '\'';
        }

        if(!String.isEmpty(filterProduct.Version__c)){
            whereCondition += ' AND Version__c LIKE \'%' + filterProduct.Version__c + '%\'';
        }

        if(!String.isEmpty(filterProduct.Status__c)){
            whereCondition += ' AND Status__c=\'' + filterProduct.Status__c + '\'';
        }

        if(!String.isEmpty(filterProduct.DescriptionSAP__c)){
            whereCondition += ' AND DescriptionSAP__c LIKE \'%' + filterProduct.DescriptionSAP__c + '%\'';
        }

        if(!String.isEmpty(filterProduct.CategoryFamily__c)){
            whereCondition += ' AND CategoryFamily__c=\'' + filterProduct.CategoryFamily__c + '\'';
        }
        return whereCondition;
    }

    public static Object runProductOptionAssociation(String productOptionId, List<String> recordList, Boolean selectedAll){
        return '';
    }

    public class HDT_WRP_RespObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String recordCounter;
        @AuraEnabled public List<Product2> prodList;
    }

}