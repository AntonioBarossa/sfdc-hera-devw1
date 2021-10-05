public inherited sharing class HDT_SRV_RuleAssociation {

    public static Object getProductList(String filterString, String ruleId, String dmlContext, Boolean usePagination, String pageNumber){

        System.debug(logginglevel.DEBUG, '>>> filterString: ' + filterString);
        System.debug(logginglevel.DEBUG, '>>> ruleId: ' + ruleId);
        System.debug(logginglevel.DEBUG, '>>> dmlContext: ' + dmlContext);
        System.debug(logginglevel.DEBUG, '>>> usePagination: ' + usePagination);
        System.debug(logginglevel.DEBUG, '>>> pageNumber: ' + pageNumber);

        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj respObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj();

        try{
            String queryString = HDT_UTL_RuleAssociation.generateQueryString(filterString, 'AND', ruleId, dmlContext);

            if(!usePagination){
                Integer recordCounter = HDT_QR_ProductAssociation.getCountOfNonConfiguredProduct2(queryString);
                System.debug(logginglevel.DEBUG, '>>> recordCounter: ' + recordCounter);
                respObj.recordCounter = String.valueOf(recordCounter);
            }
            
            queryString += HDT_SRV_ProductAssociation.generateOffSetString(pageNumber);
            respObj.prodList = HDT_QR_ProductAssociation.getIdsNonConfiguredProduct2(respObj.prodList, queryString);
            respObj.success = true;
            System.debug(logginglevel.DEBUG, '>>> RECORDS TOT: ' + respObj.prodList.size());

        } catch (Exception ex){
            respObj.success = false;
            respObj.message = '[' + String.valueOf(ex.getLineNumber()) + '] ' + ex.getMessage();
        }

        return respObj;
    }

    //************
    public static Object runProductOptionAssociation(String ruleId, String confRuleObj, List<String> recordList, String executionType, String filterString, String dmlContext){
        
        System.debug(logginglevel.DEBUG, '>>> ruleId: ' + ruleId);
        System.debug(logginglevel.DEBUG, '>>> confRuleObj: ' + confRuleObj);
        System.debug(logginglevel.DEBUG, '>>> recordList: ' + recordList);
        System.debug(logginglevel.DEBUG, '>>> executionType: ' + executionType);
        System.debug(logginglevel.DEBUG, '>>> filterString: ' + filterString);
        System.debug(logginglevel.DEBUG, '>>> dmlContext: ' + dmlContext);   

        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj;

        try{

            if(dmlContext.equalsIgnoreCase('insert')){
                respRunBatchObj = HDT_UTL_RuleAssociation.createProductRuleAssociation(respRunBatchObj, confRuleObj, recordList, executionType, filterString, dmlContext);
            } else if(dmlContext.equalsIgnoreCase('delete')){
                respRunBatchObj = HDT_UTL_RuleAssociation.deleteProductRuleAssociation(respRunBatchObj, ruleId, recordList, executionType, filterString, dmlContext);
            }
            

        } catch (exception ex){
            respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();
            respRunBatchObj.success = false;
            respRunBatchObj.message = '[' + String.valueOf(ex.getLineNumber()) + ']' + ex.getMessage();
        }

        return respRunBatchObj;
    }

    public static HDT_WRP_ProductAssociation.HDT_WRP_InsertResult associateProductRule(SBQQ__ConfigurationRule__c configurationRuleToClone, List<String> recordList){

        HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertResult = new HDT_WRP_ProductAssociation.HDT_WRP_InsertResult();

        //List<Product2> prod2list;
        //List<SBQQ__ProductFeature__c> productFeatureList;
        //Map<Id, Id> productIdFeatureIdMap;

        System.debug(logginglevel.DEBUG, '>>> PRODUCT RULE ID: ' + configurationRuleToClone.SBQQ__ProductRule__c);

        //prod2list = HDT_QR_ProductAssociation.getProductOption2recordBySkuId(prod2list, configurationRuleToClone.SBQQ__Product__c);

        //System.debug(logginglevel.DEBUG, '>>> prod2listsize ' + prod2list.size());
        //System.debug(logginglevel.DEBUG, '>>> family ' + prod2list[0].Family);

        //productIdFeatureIdMap = new Map<Id, Id>();

        //if(prod2list != null && prod2list.size() > 0){
        //    productFeatureList = HDT_QR_ProductAssociation.productFeatureListByFamily(productFeatureList, recordList, prod2list[0].Family);
        //    System.debug(logginglevel.DEBUG, '>>> productFeatureList ' + productFeatureList.size());
        //    productIdFeatureIdMap = HDT_UTL_ProductAssociation.generateSkuIdFeatureIdMap(productFeatureList, productIdFeatureIdMap);
        //}

        List<SBQQ__ConfigurationRule__c> configurationRuleList = new List<SBQQ__ConfigurationRule__c>();
        
        SBQQ__ConfigurationRule__c newRecord;
        for(String productId : recordList){
            newRecord = new SBQQ__ConfigurationRule__c();
            newRecord = configurationRuleToClone.clone(false, true, false, false);
            newRecord.SBQQ__Product__c = productId;

            //if(productIdFeatureIdMap.containsKey(productId)){
            //    newRecord.SBQQ__ProductFeature__c = productIdFeatureIdMap.get(productId);
            //}

            configurationRuleList.add(newRecord);
        }
        System.debug(logginglevel.DEBUG, '>>> record to insert: ' + String.valueOf(configurationRuleList));
        insertResult.errorData = new List<HDT_WRP_ProductAssociation.HDT_WRP_LineError>();
        insertResult.errorData = databaseInsert(configurationRuleList, insertResult.errorData);

        if(insertResult.errorData.size() > 0){
            insertResult.success = false;
            insertResult.message = 'Error during product option insert';
        } else {
            insertResult.success = true;
            //insertResult.message = 'No product option record found';
        }

        return insertResult;

    }

    public static List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> databaseInsert(List<SBQQ__ConfigurationRule__c> itemList, List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData){

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ConfigurationRule__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable() && objRes.isUpdateable()){

            List<Database.UpsertResult> insertResults = Database.upsert(itemList, false);

            for(Integer n=0; n<insertResults.size(); n++){
                Database.UpsertResult sr = insertResults[n];

                if (!sr.isSuccess()) {
                    // Operation failed
                    HDT_WRP_ProductAssociation.HDT_WRP_LineError lineError = new HDT_WRP_ProductAssociation.HDT_WRP_LineError();
                    for(Database.Error err : sr.getErrors()) {
                        lineError.rowId = itemList[n].SBQQ__Product__c;
                        lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    errorData.add(lineError);
                }
            }
        }

        return errorData;
    }

    public static List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> deleteProductRule(List<SBQQ__ConfigurationRule__c> productOptionToDelete, List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData){

        errorData = new List<HDT_WRP_ProductAssociation.HDT_WRP_LineError>();

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ConfigurationRule__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isDeletable()){

            List<Database.DeleteResult> deleteResults = Database.delete(productOptionToDelete, false);

            for(Integer n=0; n<deleteResults.size(); n++){
                Database.DeleteResult dr = deleteResults[n];

                if (!dr.isSuccess()) {
                    // Operation failed
                    HDT_WRP_ProductAssociation.HDT_WRP_LineError lineError = new HDT_WRP_ProductAssociation.HDT_WRP_LineError();
                    for(Database.Error err : dr.getErrors()) {
                        lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    errorData.add(lineError);
                }
            }
        }

        return errorData;

    }

}