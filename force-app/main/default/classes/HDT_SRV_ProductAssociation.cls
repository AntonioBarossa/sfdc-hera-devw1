public inherited sharing class HDT_SRV_ProductAssociation {

    public static Integer batchLimit = 10;

    public static Object getAsyncApexJob(String objType){
        System.debug(logginglevel.DEBUG, '>>> objType: ' + objType);

        List<String> apexJobClass = new List<String>();

        if(objType.equalsIgnoreCase('SBQQ__ProductOption__c')){
            apexJobClass.add('HDT_BA_DeleteProductAssociation');
            apexJobClass.add('HDT_BA_ProductAssociation');
        } else if(objType.equalsIgnoreCase('SBQQ__ProductRule__c')){
            apexJobClass.add('HDT_BA_DeleteProductRuleAssociation');
            apexJobClass.add('HDT_BA_ProductRuleAssociation');
        }

        List<AsyncApexJob> asyncApexJobList = HDT_QR_ProductAssociation.getJobStatus(apexJobClass);
        return asyncApexJobList.size();
    }

    public static List<String> getFieldSet(String objApiName, String fieldSetName){
        List<String> fieldSetList = new List<String>();
        try{
            List<Schema.FieldSetMember> fieldSetMembers;
            fieldSetMembers = ((SObject)Type.forName(objApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
            for(Schema.FieldSetMember s : fieldSetMembers) {
                fieldSetList.add(String.valueOf(s.getFieldPath()));
            }

        } catch(Exception ex){
            System.debug(logginglevel.DEBUG, '>>> ERROR: ' + ex.getMessage() + ' [' + ex.getLineNumber() + ']');
        }

        return fieldSetList;
    }

    public static Object getProductList(String filterString, String optionalSkuId, String dmlContext, Boolean usePagination, String pageNumber){

        System.debug(logginglevel.DEBUG, '>>> filterString: ' + filterString);
        System.debug(logginglevel.DEBUG, '>>> optionalSkuId: ' + optionalSkuId);
        System.debug(logginglevel.DEBUG, '>>> dmlContext: ' + dmlContext);
        System.debug(logginglevel.DEBUG, '>>> usePagination: ' + usePagination);
        System.debug(logginglevel.DEBUG, '>>> pageNumber: ' + pageNumber);

        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj respObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj();

        try{
            String queryString = HDT_UTL_ProductAssociation.generateQueryString(filterString, 'AND', optionalSkuId, dmlContext);

            if(!usePagination){
                Integer recordCounter = HDT_QR_ProductAssociation.getCountOfNonConfiguredProduct2(queryString);
                System.debug(logginglevel.DEBUG, '>>> recordCounter: ' + recordCounter);
                respObj.recordCounter = String.valueOf(recordCounter);
            }
            
            queryString += generateOffSetString(pageNumber);
            respObj.prodList = HDT_QR_ProductAssociation.getIdsNonConfiguredProduct2(respObj.prodList, queryString);
            respObj.success = true;
            System.debug(logginglevel.DEBUG, '>>> RECORDS TOT: ' + respObj.prodList.size());

        } catch (Exception ex){
            respObj.success = false;
            respObj.message = '[' + String.valueOf(ex.getLineNumber()) + '] ' + ex.getMessage();
        }

        return respObj;
    }

    public static String generateOffSetString(String pageNumberString){
        String offSetString = ' LIMIT 200';

        Integer pageNumber = Integer.valueOf(pageNumberString);
        offSetString += ' OFFSET ' + String.valueOf(((pageNumber-1)*200));

        return offSetString;
    }

    public static Object runProductOptionAssociation(String optionalSkuId, String productOptionObj, List<String> recordList, String executionType, String filterString, String dmlContext){
        
        System.debug(logginglevel.DEBUG, '>>> optionalSkuId: ' + optionalSkuId);
        System.debug(logginglevel.DEBUG, '>>> productOptionObj: ' + productOptionObj);
        System.debug(logginglevel.DEBUG, '>>> recordList: ' + recordList);
        System.debug(logginglevel.DEBUG, '>>> recordList: ' + recordList.size());
        System.debug(logginglevel.DEBUG, '>>> executionType: ' + executionType);
        System.debug(logginglevel.DEBUG, '>>> filterString: ' + filterString);
        System.debug(logginglevel.DEBUG, '>>> dmlContext: ' + dmlContext);   

        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj;

        try{

            if(dmlContext.equalsIgnoreCase('insert')){
                respRunBatchObj = HDT_UTL_ProductAssociation.createProductOptionAssociation(respRunBatchObj, productOptionObj, recordList, executionType, filterString, dmlContext);
            } else if(dmlContext.equalsIgnoreCase('delete')){
                respRunBatchObj = HDT_UTL_ProductAssociation.deleteProductOptionAssociation(respRunBatchObj, optionalSkuId, recordList, executionType, filterString, dmlContext);
            }
            

        } catch (exception ex){
            respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();
            respRunBatchObj.success = false;
            respRunBatchObj.message = '[' + String.valueOf(ex.getLineNumber()) + ']' + ex.getMessage();
        }

        return respRunBatchObj;
    }

    public static HDT_WRP_ProductAssociation.HDT_WRP_InsertResult associateProductOption(SBQQ__ProductOption__c productOptionToClone, List<String> recordList){

        HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertResult = new HDT_WRP_ProductAssociation.HDT_WRP_InsertResult();

        AggregateResult[] results = HDT_QR_ProductAssociation.getCountFromProductOption(recordList);
        Map<String, Integer> optionIdToNumber;
        List<Product2> prod2list;
        List<SBQQ__ProductFeature__c> productFeatureList;
        Map<Id, Id> skuIdFeatureIdMap;

        if(results.size()>0){
            optionIdToNumber = HDT_UTL_ProductAssociation.createNumberProductOptionMap(results);
        }

        System.debug(logginglevel.DEBUG, '>>> OptionalSKU ' + productOptionToClone.SBQQ__OptionalSKU__c);

        prod2list = HDT_QR_ProductAssociation.getProductOption2recordBySkuId(prod2list, productOptionToClone.SBQQ__OptionalSKU__c);

        System.debug(logginglevel.DEBUG, '>>> prod2listsize ' + prod2list.size());
        System.debug(logginglevel.DEBUG, '>>> family ' + prod2list[0].Family);

        skuIdFeatureIdMap = new Map<Id, Id>();

        if(prod2list != null && prod2list.size() > 0){
            productFeatureList = HDT_QR_ProductAssociation.productFeatureListByFamily(productFeatureList, recordList, prod2list[0].Family);
            System.debug(logginglevel.DEBUG, '>>> productFeatureList ' + productFeatureList.size());
            skuIdFeatureIdMap = HDT_UTL_ProductAssociation.generateSkuIdFeatureIdMap(productFeatureList, skuIdFeatureIdMap);
        }

        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        
        //if(productOptionToClone != null){
            SBQQ__ProductOption__c newRecord;
            for(String productId : recordList){
                newRecord = new SBQQ__ProductOption__c();
                newRecord = productOptionToClone.clone(false, true, false, false);
                newRecord.SBQQ__ConfiguredSKU__c = productId;

                if(optionIdToNumber != null && optionIdToNumber.containsKey(productId)){
                    newRecord.SBQQ__Number__c = optionIdToNumber.get(productId) + 1;
                } else {
                    newRecord.SBQQ__Number__c = 1;
                }

                if(skuIdFeatureIdMap.containsKey(productId)){
                    newRecord.SBQQ__Feature__c = skuIdFeatureIdMap.get(productId);
                }

                productOptionList.add(newRecord);
            }
            System.debug(logginglevel.DEBUG, '>>> record to insert: ' + String.valueOf(productOptionList));
            insertResult.errorData = new List<HDT_WRP_ProductAssociation.HDT_WRP_LineError>();
            insertResult.errorData = databaseInsert(productOptionList, insertResult.errorData);

            if(insertResult.errorData.size() > 0){
                insertResult.success = false;
                insertResult.message = 'Error during product option insert';
            } else {
                insertResult.success = true;
                //insertResult.message = 'No product option record found';
            }
        //} else {
        //    insertResult.success = false;
        //    insertResult.message = 'No product option record found';
        //}

        return insertResult;

    }

    public static List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> databaseInsert(List<SBQQ__ProductOption__c> itemList, List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData){

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ProductOption__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isCreateable() && objRes.isUpdateable()){

            List<Database.UpsertResult> insertResults = Database.upsert(itemList, false);

            for(Integer n=0; n<insertResults.size(); n++){
                Database.UpsertResult sr = insertResults[n];

                if (!sr.isSuccess()) {
                    // Operation failed
                    HDT_WRP_ProductAssociation.HDT_WRP_LineError lineError = new HDT_WRP_ProductAssociation.HDT_WRP_LineError();
                    for(Database.Error err : sr.getErrors()) {
                        lineError.rowId = itemList[n].SBQQ__ConfiguredSKU__c;
                        lineError.errorMessage = ' [' + err.getStatusCode() + ': ' + err.getMessage() + ' on field: ' + err.getFields() + ']';
                    }
                    errorData.add(lineError);
                }
            }
        }

        return errorData;
    }

    public static List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> deleteProductOption(List<SBQQ__ProductOption__c> productOptionToDelete, List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData){

        errorData = new List<HDT_WRP_ProductAssociation.HDT_WRP_LineError>();

        SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ProductOption__c');
        Schema.DescribeSObjectResult objRes = objtype.getDescribe();
 
        if(objRes.isDeletable()){

            List<Database.DeleteResult> deleteResults;
            deleteResults = Database.delete(productOptionToDelete, false);

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