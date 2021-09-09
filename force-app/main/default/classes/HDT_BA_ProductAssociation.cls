public without sharing class HDT_BA_ProductAssociation implements Database.Batchable<sObject>, Database.Stateful {

    //HDT_BA_ProductAssociation deepClone = new HDT_BA_ProductAssociation();
    //Id batchId = Database.executeBatch(deepClone, 20);

    public Integer recordsProcessed = 0;
    public Map<String, String> errorCloneMap;
    public SBQQ__ProductOption__c productOptionToClone;
    public String queryString;
    public String batchType = '';
    public List<String> idList;

    // 1 - RUN BATCH FOR ALL PRODUCT2
    public HDT_BA_ProductAssociation(SBQQ__ProductOption__c prodOptToClone){
        productOptionToClone = prodOptToClone;//HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);
        List<String> familyList = HDT_SRV_ProductAssociation.getFamilyList();

        queryString = 'SELECT Id ';
        queryString += 'FROM Product2 ';
        queryString += 'WHERE Status__c=\'In Sviluppo\' AND Family IN (\'' + String.join(familyList, '\',\'') + '\')';
        batchType = 'all';
    }

    // 2 - RUN BATCH FOR SELECTED PRODUCT2 LIST
    public HDT_BA_ProductAssociation(SBQQ__ProductOption__c prodOptToClone, List<String> productIdList){
        //productOptionToClone = HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);
        productOptionToClone = prodOptToClone;
        idList = productIdList;
        batchType = 'select';
    }

    // 3 - RUN BATCH FOR PRODUCT2 TO FILTER WITH WHERE CONDITION
    public HDT_BA_ProductAssociation(SBQQ__ProductOption__c prodOptToClone, String filterString){

        productOptionToClone = prodOptToClone;//HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);
        //String whereCondition = '';//HDT_SRV_ProductAssociation.generateWhereCondition(filterString, 'AND');
        queryString = 'SELECT Id ';
        queryString += filterString;
        batchType = 'filter';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        switch on batchType {
            when 'select' {
                queryString = 'SELECT Id ';
                queryString += 'FROM Product2 ';
                queryString += 'WHERE Id IN :idList';
            }
            when 'all' {
                
            }
            when 'filter' {
                
            }
        }

        System.debug('>>> QUERY: ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Product2> chunkList){
        List<SBQQ__ProductOption__c> productOptionList = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c newRecord;
        for(Product2 product : chunkList){
            newRecord = new SBQQ__ProductOption__c();
            newRecord = productOptionToClone.clone(false, true, false, false);
            newRecord.SBQQ__ConfiguredSKU__c = product.Id;
            productOptionList.add(newRecord);
        }
        System.debug('>>> record to insert: ' + productOptionList.size());

        HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertResult = new HDT_WRP_ProductAssociation.HDT_WRP_InsertResult();
        
        if(productOptionList.size() > 0){
            List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData = new List<HDT_WRP_ProductAssociation.HDT_WRP_LineError>();
            errorData = HDT_SRV_ProductAssociation.databaseInsert(productOptionList, errorData);

            if(errorData.size() > 0){
                insertResult.success = false;
                insertResult.message = 'Error during product option insert';
            } else {
                insertResult.success = true;
                //insertResult.message = 'No product option record found';
            }
        }

    }

    public void finish(Database.BatchableContext bc){}

}