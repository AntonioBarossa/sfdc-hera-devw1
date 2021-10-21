public inherited sharing class HDT_LC_ProductAssociation {

    @AuraEnabled
    public static Boolean getEnabledUser(){
        return HDT_UTL_ProductAssociation.getEnabledUser();
    }

    @AuraEnabled
    public static Object getAsyncApexJob(String objType){
        return HDT_SRV_ProductAssociation.getAsyncApexJob(objType);
    }

    @AuraEnabled
    public static List<String> getFieldSet(String objApiName, String fieldSetName){
        return HDT_SRV_ProductAssociation.getFieldSet(objApiName, fieldSetName);
    }

    @AuraEnabled
    public static Object getProductList(String objType, String filterString, String childRecordId, String dmlContext, Boolean usePagination, String pageNumber){
        Object obj;
        if(objType.equalsIgnoreCase('SBQQ__ProductOption__c')){
            obj = HDT_SRV_ProductAssociation.getProductList(filterString, childRecordId, dmlContext, usePagination, pageNumber);
        } else if(objType.equalsIgnoreCase('SBQQ__ConfigurationRule__c')){
            obj = HDT_SRV_RuleAssociation.getProductList(filterString, childRecordId, dmlContext, usePagination, pageNumber);
        }
        return obj;
    }

    @AuraEnabled
    public static Object runProductOptionAssociation(String objType, String childRecordId, String junctionObj, List<String> recordList, String executionType, String filterString, String dmlContext){
        Object obj;
        if(objType.equalsIgnoreCase('SBQQ__ProductOption__c')){
            obj = HDT_SRV_ProductAssociation.runProductOptionAssociation(childRecordId, junctionObj, recordList, executionType, filterString, dmlContext);
        } else if(objType.equalsIgnoreCase('SBQQ__ConfigurationRule__c')){
            obj = HDT_SRV_RuleAssociation.runProductOptionAssociation(childRecordId, junctionObj, recordList, executionType, filterString, dmlContext);
        }
        return obj;
    }

}