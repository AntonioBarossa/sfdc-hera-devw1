public without sharing class HDT_BA_ProductAssociation implements Database.Batchable<sObject>, Database.Stateful {

    //HDT_BA_ProductAssociation deepClone = new HDT_BA_ProductAssociation();
    //Id batchId = Database.executeBatch(deepClone, 20);

    public Integer recordsProcessed = 0;
    public Map<String, String> errorCloneMap;
    public SBQQ__ProductOption__c productOptionToClone;
    public String queryString;

    // 1 - RUN BATCH FOR ALL PRODUCT2
    public HDT_BA_ProductAssociation(Id productOptionId){
        productOptionToClone = HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);
        queryString += 'SELECT Id ';
        queryString += 'FROM Product2 ';
    }

    // 2 - RUN BATCH FOR FILTERED PRODUCT2 LIST
    public HDT_BA_ProductAssociation(Id productOptionId, List<Id> productIdList){
        productOptionToClone = HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);

        queryString += 'SELECT Id ';
        queryString += 'FROM Product2 ';
        queryString += 'WHERE Id IN :productIdList';
    }

    // 3 - RUN BATCH FOR PRODUCT2 TO FILTER WITH WHERE CONDITION
    public HDT_BA_ProductAssociation(Id productOptionId, String filterString){
        productOptionToClone = HDT_QR_ProductAssociation.getProductOptionRecordById(productOptionId);

        String whereCondition = HDT_SRV_ProductAssociation.generateWhereCondition(filterString, 'AND');

        queryString += 'SELECT Id ';
        queryString += 'FROM Product2 ';
        queryString += whereCondition;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
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
    }

    public void finish(Database.BatchableContext bc){}

}