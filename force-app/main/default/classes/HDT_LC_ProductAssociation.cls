public inherited sharing class HDT_LC_ProductAssociation {

    @AuraEnabled
    public static Object getProductList(String filterString, String optionalSkuId){
        return HDT_SRV_ProductAssociation.getProductList(filterString, optionalSkuId);
    }

    @AuraEnabled
    public static Object runProductOptionAssociation(String productOptionId, List<String> recordList, String executionType){
        return HDT_SRV_ProductAssociation.runProductOptionAssociation(productOptionId, recordList, executionType);
    }

}