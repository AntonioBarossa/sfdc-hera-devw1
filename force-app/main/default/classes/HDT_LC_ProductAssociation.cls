public inherited sharing class HDT_LC_ProductAssociation {

    @AuraEnabled
    public static Object getProductList(String filterString, String optionalSkuId, String findMethod){
        return HDT_SRV_ProductAssociation.getProductList(filterString, optionalSkuId, findMethod);
    }

    @AuraEnabled
    public static Object runProductOptionAssociation(String optionalSkuId, String productOptionObj, List<String> recordList, String executionType, String filterString, String findMethod){
        return HDT_SRV_ProductAssociation.runProductOptionAssociation(optionalSkuId, productOptionObj, recordList, executionType, filterString, findMethod);
    }

}