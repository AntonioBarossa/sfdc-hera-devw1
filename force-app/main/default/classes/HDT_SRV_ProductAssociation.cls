public inherited sharing class HDT_SRV_ProductAssociation {

    public static Integer batchLimit = 50;

    public static void getJobStatus(){
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = '' ];
    }

    public static Object getProductList(String filterString, String optionalSkuId, String findMethod){

        System.debug('>>> filterString: ' + filterString);
        System.debug('>>> optionalSkuId: ' + optionalSkuId);
        HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj respObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespQueryObj();

        try{
            String queryString = generateQueryString(filterString, 'AND', optionalSkuId, findMethod);
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

    public static String generateQueryString(String filterString, String operator, String optionalSkuId, String findMethod){
        
        String op = ' ' + operator + ' ';
        String queryString = '';
        List<String> familyList = getFamilyList();

        Product2 filterProduct = (Product2)JSON.deserialize(filterString, Product2.class);
        System.debug('>>> FILTER PRODUCT: ' + String.valueOf(filterProduct));

        List<String> whereConditionList = new List<String>();
        if(!String.isEmpty(filterProduct.Name)){
            whereConditionList.add('Name LIKE \'%' + filterProduct.Name + '%\'');
        }

        if(!String.isEmpty(filterProduct.TypeOffer__c)){
            whereConditionList.add('TypeOffer__c = \'' + filterProduct.TypeOffer__c + '\'');
        }

        if(!String.isEmpty(filterProduct.ProductCode)){
            whereConditionList.add('ProductCode LIKE \'%' + filterProduct.ProductCode + '%\'');
        }

        if(!String.isEmpty(filterProduct.Family)){
            whereConditionList.add('Family = \'' + filterProduct.Family + '\'');
        }

        if(!String.isEmpty(filterProduct.Version__c)){
            whereConditionList.add('Version__c LIKE \'%' + filterProduct.Version__c + '%\'');
        }

        if(!String.isEmpty(filterProduct.Status__c)){
            whereConditionList.add('Status__c=\'' + filterProduct.Status__c + '\'');
        }

        if(!String.isEmpty(filterProduct.DescriptionSAP__c)){
            whereConditionList.add('DescriptionSAP__c LIKE \'%' + filterProduct.DescriptionSAP__c + '%\'');
        }

        if(!String.isEmpty(filterProduct.CategoryFamily__c)){
            whereConditionList.add('CategoryFamily__c=\'' + filterProduct.CategoryFamily__c + '\'');
        }

        queryString += 'FROM Product2 ';
        queryString += 'WHERE ' + String.join(whereConditionList, op) + ' ';
        queryString += 'AND Id ';

        switch on findMethod {
            when 'insert' {
                queryString += 'NOT IN';
            }
            when 'delete' {
                queryString += 'IN';
            }
        }

        queryString +=  ' (SELECT SBQQ__ConfiguredSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = \'' + optionalSkuId + '\') ';
        queryString += 'AND Family IN (\'' + String.join(familyList, '\',\'') + '\')';
        
        return queryString;
    }

    public static Object runProductOptionAssociation(String productOptionObj, List<String> recordList, String executionType, String filterString, String findMethod){
        
        System.debug('>>> executionType: ' + executionType);
        System.debug('>>> productOptionObj: ' + productOptionObj);
        System.debug('>>> recordList: ' + recordList);

        HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();

        try{

            SBQQ__ProductOption__c productOptionToClone = (SBQQ__ProductOption__c)JSON.deserialize(productOptionObj, SBQQ__ProductOption__c.class);

            switch on executionType {
                when 'select' {
                    //run batch for selected record -> recordList > 0

                    if(recordList.size() < batchLimit){
                        // NO BATCH NEEDED, YOU CAN UPDATE HERE
                        HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertReult = associateProductOption(productOptionToClone, recordList);

                        if(insertReult.success){
                            respRunBatchObj.message = 'L\'associazione è stata eseguita correttamente';
                        } else {
                            respRunBatchObj.message = insertReult.message;
                        }
                        
                    } else {
                        
                        HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(productOptionToClone, recordList);
                        Id batchId = Database.executeBatch(createAssociationBatch);
                        respRunBatchObj.message = 'Il batch è stato lanciato correttamente';
                    }
                }	
                when 'all' {
                    //run batch for all Product2 record -> recordList == 0
                    HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(productOptionToClone);
                    Id batchId = Database.executeBatch(createAssociationBatch);
                    respRunBatchObj.message = 'Il batch è stato lanciato correttamente';
                }
                when 'filter' {
                    //run batch for all Product2 using where condition

                    //SBQQ__ProductOption__c productOptionToClone = HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);

                    String queryString = generateQueryString(filterString, 'AND', productOptionToClone.SBQQ__OptionalSKU__c, findMethod);
                    System.debug('>>> queryString: ' + queryString);

                    HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(productOptionToClone, queryString);
                    Id batchId = Database.executeBatch(createAssociationBatch);
                    respRunBatchObj.message = 'Il batch è stato lanciato correttamente';
                }
            }

            respRunBatchObj.success = true;

        } catch (exception ex){
            respRunBatchObj.success = false;
            respRunBatchObj.message = '[' + String.valueOf(ex.getLineNumber()) + ']' + ex.getMessage();
        }

        return respRunBatchObj;
    }

    public static HDT_WRP_ProductAssociation.HDT_WRP_InsertResult associateProductOption(SBQQ__ProductOption__c productOptionToClone, List<String> recordList){

        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        //HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);
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

    public static List<String> getFamilyList(){
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        sl.add('VAS Prodotto');
        sl.add('VAS Servizio');
        return sl;
    }

}