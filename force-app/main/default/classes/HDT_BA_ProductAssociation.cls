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
            //when 'all' {
            //    // 2 - RUN BATCH FOR ALL PRODUCT2
            //    List<String> familyList = HDT_UTL_ProductAssociation.getFamilyList();
            //    queryString += 'FROM Product2 ';
            //    queryString += 'WHERE Status__c=\'In Sviluppo\' AND Family IN :familyList';
            //}
            when 'filter' {
                // 3 - RUN BATCH FOR PRODUCT2 TO FILTER WITH WHERE CONDITION
                queryString += filterString;
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
                errorCounter += errorData.size();
            } else {
                insertResult.success = true;
                //insertResult.message = 'No product option record found';
            }
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