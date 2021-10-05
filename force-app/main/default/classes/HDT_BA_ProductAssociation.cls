public without sharing class HDT_BA_ProductAssociation implements Database.Batchable<sObject>, Database.Stateful {

    public SBQQ__ProductOption__c productOptionToClone;
    public String queryString;
    public String batchType = '';
    public List<String> idList;
    public String filterString;
    public Integer errorCounter;

    public HDT_BA_ProductAssociation(String type, SBQQ__ProductOption__c prodOptToClone, List<String> productIdList, String filter){
        productOptionToClone = prodOptToClone;
        idList = productIdList;
        batchType = type;
        filterString = filter;
        errorCounter = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        queryString = 'SELECT Id ';

        switch on batchType {
            when 'select' {
                // 1 - RUN BATCH FOR SELECTED PRODUCT2 LIST
                queryString += 'FROM Product2 ';
                queryString += 'WHERE Id IN :idList';
            }
            when 'filter' {
                // 3 - RUN BATCH FOR PRODUCT2 TO FILTER WITH WHERE CONDITION
                queryString += filterString;
            }
            when else {
                queryString = null;
            }
        }

        System.debug(logginglevel.DEBUG, '>>> QUERY: ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<Product2> chunkList){

        List<String> recordList = new List<String>();
        for(Product2 product : chunkList){
            recordList.add(product.Id);
        }
        HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertResult;
        insertResult = HDT_SRV_ProductAssociation.associateProductOption(productOptionToClone, recordList);

        if(insertResult.errorData.size() > 0){
            errorCounter += insertResult.errorData.size();
        }

    }

    public void finish(Database.BatchableContext bc){
        ////METHOD TO SEND EMAIL NOTIFICATION
        HDT_WRP_ProductAssociation.HDT_WRP_Notification notification;
        notification = new HDT_WRP_ProductAssociation.HDT_WRP_Notification();
        notification.targetId = productOptionToClone.SBQQ__OptionalSKU__c;
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