public inherited sharing class HDT_LC_ProductAssociation {

    @AuraEnabled
    public static Object getProductList(String filterString){
        return HDT_SRV_ProductAssociation.getProductList(filterString);
    }

    @AuraEnabled
    public static Object runProductOptionAssociation(String productOptionId, List<String> recordList, String executionType){
        return HDT_SRV_ProductAssociation.runProductOptionAssociation(productOptionId, recordList, executionType);
    }

}