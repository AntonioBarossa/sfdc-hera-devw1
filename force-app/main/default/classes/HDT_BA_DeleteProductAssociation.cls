public without sharing class HDT_BA_DeleteProductAssociation implements Database.Batchable<sObject>, Database.Stateful {

    public String queryString;
    public String optionalSkuIdToDelete;
    public List<String> idListToDelete;
    public String batchType;
    public String filterProductString;

    public HDT_BA_DeleteProductAssociation(String type, String optionalSkuId, List<String> productIdList, String filter){
        optionalSkuIdToDelete = optionalSkuId;
        idListToDelete = productIdList;
        batchType = type;
        filterProductString = filter;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        queryString = 'SELECT Id ';
        queryString += 'FROM SBQQ__ProductOption__c ';

        switch on batchType {
            when 'select' {
                // 1 - RUN BATCH FOR SELECTED SBQQ__ProductOption__c LIST
                queryString += 'WHERE SBQQ__ConfiguredSKU__c IN :idListToDelete AND SBQQ__OptionalSKU__c = :optionalSkuIdToDelete';
            }
            when 'all' {
                // 2 - RUN BATCH FOR ALL SBQQ__ProductOption__c
                List<String> familyList = HDT_UTL_ProductAssociation.getFamilyList();
                queryString += 'WHERE SBQQ__OptionalSKU__c = :optionalSkuIdToDelete';
            }
            when 'filter' {
                // 3 - RUN BATCH FOR SBQQ__ProductOption__c TO FILTER WITH WHERE CONDITION

                List<Product2> productFiltered;
                productFiltered = HDT_QR_ProductAssociation.getIdsNonConfiguredProduct2(productFiltered, filterProductString);
                System.debug('>>>> PRODUCT FILTERED ' + productFiltered.size());
                
                queryString += 'WHERE SBQQ__ConfiguredSKU__c IN :productFiltered AND SBQQ__OptionalSKU__c = :optionalSkuIdToDelete';
            }
        }

        System.debug('>>> QUERY: ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<SBQQ__ProductOption__c> chunkList){
        System.debug('>>> EXECUTE');
        System.debug('>>> delete: ' + chunkList.size());
        for(SBQQ__ProductOption__c prodOpt : chunkList){
            System.debug('>>> ' + prodOpt.Id);
        }

        //List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData;
        //errorData = HDT_SRV_ProductAssociation.deleteProductOption(chunkList, errorData);

    }

    public void finish(Database.BatchableContext bc){
        //METHOD TO SEND EMAIL NOTIFICATION
    }

}