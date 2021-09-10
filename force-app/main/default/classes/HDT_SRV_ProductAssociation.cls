public inherited sharing class HDT_SRV_ProductAssociation {

    public static Integer batchLimit = 50;

    public static void getJobStatus(){
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID = '' ];
    }

    public static Object getProductList(String filterString, String optionalSkuId){

        System.debug('>>> filterString: ' + filterString);
        System.debug('>>> optionalSkuId: ' + optionalSkuId);
        HDT_WRP_RespQueryObj respObj = new HDT_WRP_RespQueryObj();

        try{
            String whereCondition = generateWhereCondition(filterString, 'AND');
            System.debug('>>> whereCondition: ' + whereCondition);
            
            List<String> familyList = getFamilyList();

            String queryString = '';
            queryString += 'FROM Product2';
            queryString += whereCondition;
            queryString += ' AND Id NOT IN (SELECT SBQQ__ConfiguredSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c = :optionalSkuId)';
            queryString += ' AND Family IN: familyList';

            Integer recordCounter = HDT_QR_ProductAssociation.getCountOfNonConfiguredProduct2(whereCondition, optionalSkuId, familyList, queryString);
            System.debug('>>> recordCounter: ' + recordCounter);

            respObj.success = true;
            respObj.recordCounter = String.valueOf(recordCounter);
            respObj.prodList = HDT_QR_ProductAssociation.getIdsNonConfiguredProduct2(respObj.prodList, whereCondition, optionalSkuId, familyList, queryString);
            System.debug('>>> RECORDS TOT: ' + respObj.prodList.size());

        } catch (Exception ex){
            respObj.success = false;
            respObj.message = '[' + String.valueOf(ex.getLineNumber()) + '] ' + ex.getMessage();
        }

        return respObj;
    }

    public static String generateWhereCondition(String filterString, String operator){
        
        String op = ' ' + operator + ' ';

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
        return ' WHERE ' + String.join(whereConditionList, op);
    }

    public static Object runProductOptionAssociation(String productOptionId, List<String> recordList, String executionType){
        
        System.debug('>>> executionType: ' + executionType);
        System.debug('>>> productOptionId: ' + productOptionId);
        System.debug('>>> recordList: ' + recordList);

        HDT_WRP_RespRunBatchObj respRunBatchObj = new HDT_WRP_RespRunBatchObj();

        try{

            switch on executionType {
                when 'select' {
                    //run batch for selected record -> recordList > 0

                    if(recordList.size() < batchLimit){
                        // NO BATCH NEEDED, YOU CAN UPDATE HERE
                        associateProductOption(productOptionId, recordList);
                        respRunBatchObj.message = 'L\'associazione è stata eseguita correttamente';
                    } else {
                        HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(productOptionId, recordList);
                        Id batchId = Database.executeBatch(createAssociationBatch);
                        respRunBatchObj.message = 'Il batch è stato lanciato correttamente';
                    }
                }	
                when 'all' {
                    //run batch for all Product2 record -> recordList == 0
                    HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(productOptionId);
                    Id batchId = Database.executeBatch(createAssociationBatch);
                    respRunBatchObj.message = 'Il batch è stato lanciato correttamente';
                }
                when 'filter' {
                    //run batch for all Product2 using where condition
                    HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(productOptionId, '');
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

    public static void associateProductOption(String productOptionId, List<String> recordList){

        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c productOptionToClone = HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);
        
        SBQQ__ProductOption__c newRecord;
        for(String productId : recordList){
            newRecord = new SBQQ__ProductOption__c();
            newRecord = productOptionToClone.clone(false, true, false, false);
            newRecord.SBQQ__ConfiguredSKU__c = productId;
            productOptionList.add(newRecord);
        }
        System.debug('>>> record to insert: ' + String.valueOf(productOptionList));
        //insert productOptionList;
    }

    public static List<String> getFamilyList(){
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        sl.add('VAS Prodotto');
        sl.add('VAS Servizio');
        return sl;
    }

    public class HDT_WRP_RespQueryObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String recordCounter;
        @AuraEnabled public List<Product2> prodList;
    }

    public class HDT_WRP_RespRunBatchObj {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }

}