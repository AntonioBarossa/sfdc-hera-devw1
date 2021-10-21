public without sharing class HDT_BA_DeleteProductAssociation implements Database.Batchable<sObject>, Database.Stateful {

    public String queryString;
    public String optionalSkuIdToDelete;
    public List<String> idListToDelete;
    public String batchType;
    public String filterProductString;
    public Integer errorCounter;

    public HDT_BA_DeleteProductAssociation(String type, String optionalSkuId, List<String> productIdList, String filter){
        optionalSkuIdToDelete = optionalSkuId;
        idListToDelete = productIdList;
        batchType = type;
        filterProductString = filter;
        errorCounter = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String queryString = '';
        String queryStringTemp = '';
        queryStringTemp = 'SELECT Id ';
        queryStringTemp += 'FROM SBQQ__ProductOption__c ';

        switch on batchType {
            when 'select' {
                // 1 - RUN BATCH FOR SELECTED SBQQ__ProductOption__c LIST
                queryStringTemp += 'WHERE SBQQ__ConfiguredSKU__c IN :idListToDelete AND SBQQ__OptionalSKU__c = :optionalSkuIdToDelete';
                queryString = queryStringTemp;
            }
            when 'filter' {
                // 3 - RUN BATCH FOR SBQQ__ProductOption__c TO FILTER WITH WHERE CONDITION

                List<Product2> productFiltered;
                productFiltered = HDT_QR_ProductAssociation.getIdsNonConfiguredProduct2(productFiltered, filterProductString);
                System.debug(logginglevel.DEBUG, '>>>> PRODUCT FILTERED ' + productFiltered.size());
                
                queryStringTemp += 'WHERE SBQQ__ConfiguredSKU__c IN :productFiltered AND SBQQ__OptionalSKU__c = :optionalSkuIdToDelete';
                queryString = queryStringTemp;
            }
            when else {
                queryString = null;
            }
        }

        System.debug(logginglevel.DEBUG, '>>> QUERY: ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<SBQQ__ProductOption__c> chunkList){
        System.debug(logginglevel.DEBUG, '>>> EXECUTE');
        System.debug(logginglevel.DEBUG, '>>> delete: ' + chunkList.size());
        for(SBQQ__ProductOption__c prodOpt : chunkList){
            System.debug(logginglevel.DEBUG, '>>> ' + prodOpt.Id);
        }

        List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData;
        errorData = HDT_SRV_ProductAssociation.deleteProductOption(chunkList, errorData);

        if(errorData.size() > 0){
            errorCounter += errorData.size();
        }

    }

    public void finish(Database.BatchableContext bc){
        //METHOD TO SEND EMAIL NOTIFICATION
        HDT_WRP_ProductAssociation.HDT_WRP_Notification notification;
        notification = new HDT_WRP_ProductAssociation.HDT_WRP_Notification();
        notification.targetId = optionalSkuIdToDelete;
        notification.userId = Userinfo.getUserId();
        notification.title = Label.ProdOptAssociationNotification_Title;

        if(errorCounter > 0){
            notification.body = 'Attenzione, si sono verificati [' + String.valueOf(errorCounter) + '] errori';
        } else {
            notification.body = Label.ProdOptAssociationNotification_Body;
        }

        HDT_UTL_ProductAssociation.sendCustomNotification(notification);
    }

}