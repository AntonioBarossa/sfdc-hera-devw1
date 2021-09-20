public inherited sharing class HDT_SRV_ProductAssociation {

    public static Integer batchLimit = 10;

    public static List<String> getFieldSet(String fieldSetName){
        List<String> fieldSetList = new List<String>();
        try{
            //List<Schema.FieldSetMember> fieldSetMembers;
            //fieldSetMembers = ((SObject)Type.forName('SBQQ__ProductOption__c').newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
            //for(Schema.FieldSetMember s : fieldSetMembers) {
            //    fieldSetList.add(String.valueOf(s.getFieldPath()));
            //}

            //fieldSetList.add('SBQQ__Feature__c');
            fieldSetList.add('SBQQ__Type__c');
            fieldSetList.add('SBQQ__Quantity__c');           
            fieldSetList.add('SBQQ__MinQuantity__c');
            fieldSetList.add('SBQQ__MaxQuantity__c');
            fieldSetList.add('SBQQ__Discount__c');
            fieldSetList.add('SBQQ__DiscountAmount__c');
            fieldSetList.add('SBQQ__Selected__c');
            fieldSetList.add('SBQQ__QuantityEditable__c');

        } catch(Exception ex){
            System.debug('>>> ERROR: ' + ex.getMessage() + ' [' + ex.getLineNumber() + ']');
        }

        return fieldSetList;
    }

    public static Object getProductList(String filterString, String optionalSkuId, String dmlContext, Boolean usePagination, String pageNumber){

        System.debug('>>> filterString: ' + filterString);
        System.debug('>>> optionalSkuId: ' + optionalSkuId);
        System.debug('>>> dmlContext: ' + dmlContext);
        System.debug('>>> usePagination: ' + usePagination);
        System.debug('>>> pageNumber: ' + pageNumber);

        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj respObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj();

        try{
            String queryString = HDT_UTL_ProductAssociation.generateQueryString(filterString, 'AND', optionalSkuId, dmlContext);

            if(!usePagination){
                Integer recordCounter = HDT_QR_ProductAssociation.getCountOfNonConfiguredProduct2(queryString);
                System.debug('>>> recordCounter: ' + recordCounter);
                respObj.recordCounter = String.valueOf(recordCounter);
            }
            
            queryString += generateOffSetString(pageNumber);
            respObj.prodList = HDT_QR_ProductAssociation.getIdsNonConfiguredProduct2(respObj.prodList, queryString);
            respObj.success = true;
            System.debug('>>> RECORDS TOT: ' + respObj.prodList.size());

        } catch (Exception ex){
            respObj.success = false;
            respObj.message = '[' + String.valueOf(ex.getLineNumber()) + '] ' + ex.getMessage();
        }

        return respObj;
    }

    public static String generateOffSetString(String pageNumberString){
        String offSetString = ' LIMIT 200';

        Integer pageNumber = Integer.valueOf(pageNumberString);
        //offSetString += String.valueOf((pageNumber*200)) + ' OFFSET ' + String.valueOf(((pageNumber-1)*200));
        offSetString += ' OFFSET ' + String.valueOf(((pageNumber-1)*200));

        return offSetString;
    }

    public static Object runProductOptionAssociation(String optionalSkuId, String productOptionObj, List<String> recordList, String executionType, String filterString, String dmlContext){
        
        System.debug('>>> optionalSkuId: ' + optionalSkuId);
        System.debug('>>> productOptionObj: ' + productOptionObj);
        System.debug('>>> recordList: ' + recordList);
        System.debug('>>> executionType: ' + executionType);
        System.debug('>>> filterString: ' + filterString);
        System.debug('>>> dmlContext: ' + dmlContext);   

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

        System.debug('>>> OptionalSKU ' + productOptionToClone.SBQQ__OptionalSKU__c);

        prod2list = HDT_QR_ProductAssociation.getProductOption2recordBySkuId(prod2list, productOptionToClone.SBQQ__OptionalSKU__c);

        System.debug('>>> prod2listsize ' + prod2list.size());
        System.debug('>>> family ' + prod2list[0].Family);

        skuIdFeatureIdMap = new Map<Id, Id>();

        if(prod2list != null && prod2list.size() > 0){
            productFeatureList = HDT_QR_ProductAssociation.productFeatureListByFamily(productFeatureList, recordList, prod2list[0].Family);
            System.debug('>>> productFeatureList ' + productFeatureList.size());
            skuIdFeatureIdMap = HDT_UTL_ProductAssociation.generateSkuIdFeatureIdMap(productFeatureList, skuIdFeatureIdMap);
        }

        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        
        if(productOptionToClone != null){
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
            System.debug('>>> record to insert: ' + String.valueOf(productOptionList));
            insertResult.errorData = new List<HDT_WRP_ProductAssociation.HDT_WRP_LineError>();
            insertResult.errorData = databaseInsert(productOptionList, insertResult.errorData);

            if(insertResult.errorData.size() > 0){
                insertResult.success = false;
                insertResult.message = 'Error during product option insert';
            } else {
                insertResult.success = true;
                //insertResult.message = 'No product option record found';
            }
        } else {
            insertResult.success = false;
            insertResult.message = 'No product option record found';
        }

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
                    String errorString = '';
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

            List<Database.DeleteResult> deleteResults = Database.delete(productOptionToDelete, false);

            for(Integer n=0; n<deleteResults.size(); n++){
                Database.DeleteResult dr = deleteResults[n];

                if (!dr.isSuccess()) {
                    // Operation failed
                    String errorString = '';
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