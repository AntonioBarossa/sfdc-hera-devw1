public inherited sharing class HDT_SRV_ProductAssociation {

    public static Integer batchLimit = 1;

    public static Object getProductList(String filterString, String optionalSkuId, String findMethod){

        System.debug('>>> filterString: ' + filterString);
        System.debug('>>> optionalSkuId: ' + optionalSkuId);
        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj respObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj();

        try{
            String queryString = HDT_UTL_ProductAssociation.generateQueryString(filterString, 'AND', optionalSkuId, findMethod);
            System.debug('>>> queryString: ' + queryString);
            
            Integer recordCounter = HDT_QR_ProductAssociation.getCountOfNonConfiguredProduct2(queryString);
            System.debug('>>> recordCounter: ' + recordCounter);

            respObj.success = true;
            respObj.recordCounter = String.valueOf(recordCounter);
            respObj.prodList = HDT_QR_ProductAssociation.getIdsNonConfiguredProduct2(respObj.prodList, queryString);
            System.debug('>>> RECORDS TOT: ' + respObj.prodList.size());

        } catch (Exception ex){
            respObj.success = false;
            respObj.message = '[' + String.valueOf(ex.getLineNumber()) + '] ' + ex.getMessage();
        }

        return respObj;
    }

    public static Object runProductOptionAssociation(String optionalSkuId, String productOptionObj, List<String> recordList, String executionType, String filterString, String findMethod){
        
        System.debug('>>> productOptionObj: ' + productOptionObj);
        System.debug('>>> recordList: ' + recordList);
        System.debug('>>> executionType: ' + executionType);
        System.debug('>>> filterString: ' + filterString);
        System.debug('>>> findMethod: ' + findMethod);   

        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj;

        try{

            if(findMethod.equalsIgnoreCase('insert')){
                respRunBatchObj = HDT_UTL_ProductAssociation.createProductOptionAssociation(respRunBatchObj, productOptionObj, recordList, executionType, filterString, findMethod);
            } else if(findMethod.equalsIgnoreCase('delete')){
                respRunBatchObj = HDT_UTL_ProductAssociation.deleteProductOptionAssociation(respRunBatchObj, optionalSkuId, recordList, executionType, filterString, findMethod);
            }
            

        } catch (exception ex){
            respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();
            respRunBatchObj.success = false;
            respRunBatchObj.message = '[' + String.valueOf(ex.getLineNumber()) + ']' + ex.getMessage();
        }

        return respRunBatchObj;
    }

    public static HDT_WRP_ProductAssociation.HDT_WRP_InsertResult associateProductOption(SBQQ__ProductOption__c productOptionToClone, List<String> recordList){

        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertResult = new HDT_WRP_ProductAssociation.HDT_WRP_InsertResult();
        
        if(productOptionToClone != null){
            SBQQ__ProductOption__c newRecord;
            for(String productId : recordList){
                newRecord = new SBQQ__ProductOption__c();
                newRecord = productOptionToClone.clone(false, true, false, false);
                newRecord.SBQQ__ConfiguredSKU__c = productId;
                productOptionList.add(newRecord);
            }
            System.debug('>>> record to insert: ' + String.valueOf(productOptionList));
            List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData = new List<HDT_WRP_ProductAssociation.HDT_WRP_LineError>();
            errorData = databaseInsert(productOptionList, errorData);

            if(errorData.size() > 0){
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