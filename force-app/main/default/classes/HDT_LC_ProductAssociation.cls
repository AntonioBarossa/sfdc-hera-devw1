public inherited sharing class HDT_LC_ProductAssociation {

    @AuraEnabled
    public static Object getAsyncApexJob(){
        return HDT_SRV_ProductAssociation.getAsyncApexJob();
    }

    @AuraEnabled
    public static List<String> getFieldSet(String fieldSetName){
        return HDT_SRV_ProductAssociation.getFieldSet(fieldSetName);
    }

    @AuraEnabled
    public static Object getProductList(String filterString, String optionalSkuId, String dmlContext, Boolean usePagination, String pageNumber){
        return HDT_SRV_ProductAssociation.getProductList(filterString, optionalSkuId, dmlContext, usePagination, pageNumber);
    }

    @AuraEnabled
    public static Object runProductOptionAssociation(String optionalSkuId, String productOptionObj, List<String> recordList, String executionType, String filterString, String dmlContext){
        return HDT_SRV_ProductAssociation.runProductOptionAssociation(optionalSkuId, productOptionObj, recordList, executionType, filterString, dmlContext);
    }

}