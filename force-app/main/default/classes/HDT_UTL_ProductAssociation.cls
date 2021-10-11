public inherited sharing class HDT_UTL_ProductAssociation {

    public static Boolean getEnabledUser(){
        List<GroupMember> groupMembers;
        groupMembers = HDT_QR_ProductAssociation.getGroupMembers(groupMembers, UserInfo.getUserId(), 'HDT_PG_CpqAssociationTool');
        return (groupMembers.size()==0) ? false : true;
    }

    public static String generateQueryString(String filterString, String operator, String optionalSkuId, String findMethod){
        
        String op = ' ' + operator + ' ';
        String queryString = '';
        List<String> familyList = getFamilyList();

        Product2 filterProduct = (Product2)JSON.deserialize(filterString, Product2.class);
        System.debug(logginglevel.DEBUG, '>>> FILTER PRODUCT: ' + String.valueOf(filterProduct));

        List<String> whereConditionList = new List<String>();
        if(!String.isEmpty(filterProduct.Name)){
            whereConditionList.add('Name LIKE \'%' + String.escapeSingleQuotes(filterProduct.Name) + '%\'');
        }

        if(!String.isEmpty(filterProduct.TypeOffer__c)){
            whereConditionList.add('TypeOffer__c = \'' + String.escapeSingleQuotes(filterProduct.TypeOffer__c) + '\'');
        }

        if(!String.isEmpty(filterProduct.ProductCode)){
            whereConditionList.add('ProductCode LIKE \'%' + String.escapeSingleQuotes(filterProduct.ProductCode) + '%\'');
        }

        //if(!String.isEmpty(filterProduct.Family)){
        //    whereConditionList.add('Family = \'' + filterProduct.Family + '\'');
        //}

        if(!String.isEmpty(filterProduct.Version__c)){
            whereConditionList.add('Version__c LIKE \'%' + String.escapeSingleQuotes(filterProduct.Version__c) + '%\'');
        }

        if(!String.isEmpty(filterProduct.Status__c)){
            whereConditionList.add('Status__c=\'' + String.escapeSingleQuotes(filterProduct.Status__c) + '\'');
        }

        if(!String.isEmpty(filterProduct.DescriptionSAP__c)){
            whereConditionList.add('DescriptionSAP__c LIKE \'%' + String.escapeSingleQuotes(filterProduct.DescriptionSAP__c) + '%\'');
        }

        if(!String.isEmpty(filterProduct.CategoryFamily__c)){
            whereConditionList.add('CategoryFamily__c=\'' + String.escapeSingleQuotes(filterProduct.CategoryFamily__c) + '\'');
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
        queryString += 'AND Family IN (\'' + String.join(familyList, '\',\'') + '\') ';
        queryString += 'AND (NOT Name LIKE \'template%\')';
        
        //if(!String.isEmpty(filterProduct.Family)){
        //    queryString += ',\'' + filterProduct.Family + '\'';
        //}

        //queryString += ;

        return queryString;
    }
    
    public static HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj createProductOptionAssociation(HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj, String productOptionObj, List<String> recordList, String executionType, String filterString, String findMethod){
        
        System.debug(logginglevel.DEBUG, '>>> createProductOptionAssociation');

        respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();

        if(String.isEmpty(productOptionObj)){
            respRunBatchObj.success = false;
            respRunBatchObj.message = 'Errore durante l\'elaborazione del prodotto opzione configurato';
            return respRunBatchObj;
        }

        SBQQ__ProductOption__c productOptionToClone = (SBQQ__ProductOption__c)JSON.deserialize(productOptionObj, SBQQ__ProductOption__c.class);

        switch on executionType {
            when 'select' {
                //run batch for selected record -> recordList > 0

                if(recordList.size() < 10){
                    // NO BATCH NEEDED, YOU CAN UPDATE HERE
                    HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertReult = HDT_SRV_ProductAssociation.associateProductOption(productOptionToClone, recordList);

                    if(insertReult.success){
                        respRunBatchObj.success = true;
                        respRunBatchObj.message = Label.ProdOptAssociationSuccessCreate;
                    } else {
                        respRunBatchObj.success = false;
                        respRunBatchObj.message = insertReult.message;
                    }
                    
                } else {
                    HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(executionType, productOptionToClone, recordList, '');
                    Id batchId = Database.executeBatch(createAssociationBatch);
                    respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                    respRunBatchObj.success = true;
                }
            }
            when 'filter' {
                //run batch for all Product2 using where condition

                String queryString = HDT_UTL_ProductAssociation.generateQueryString(filterString, 'AND', productOptionToClone.SBQQ__OptionalSKU__c, findMethod);
                System.debug(logginglevel.DEBUG, '>>> queryString: ' + queryString);
                
                HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(executionType, productOptionToClone, new List<String>(), queryString);
                Id batchId = Database.executeBatch(createAssociationBatch);
                respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                respRunBatchObj.success = true;
            }
        }

        return respRunBatchObj;
    }

    public static HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj deleteProductOptionAssociation(HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj, String optionalSkuId, List<String> recordList, String executionType, String filterString, String findMethod){
        
        System.debug(logginglevel.DEBUG, '>>> deleteProductOptionAssociation');
        
        respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();

        switch on executionType {
            when 'select' {
                //run batch for selected record -> recordList > 0

                if(recordList.size() < 10){
                    // NO BATCH NEEDED, YOU CAN DELETE HERE
                    List<SBQQ__ProductOption__c> productOptionToDelete;
                    productOptionToDelete = HDT_QR_ProductAssociation.getProductOptionByOptionalSkuAndConfiguredSku(productOptionToDelete, optionalSkuId, recordList);

                    SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ProductOption__c');
                    Schema.DescribeSObjectResult objRes = objtype.getDescribe();
             
                    if(objRes.isDeletable ()){
                        List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData;
                        errorData = HDT_SRV_ProductAssociation.deleteProductOption(productOptionToDelete, errorData);

                        if(errorData.size() > 0){
                            respRunBatchObj.success = false;
                            respRunBatchObj.message = 'Si sono verificati [' + String.valueOf(errorData.size()) + '] errori.';
                        } else {
                            respRunBatchObj.success = true;
                            respRunBatchObj.message = Label.ProdOptAssociationSuccessDelete;
                        }
                    }
                    
                } else {
                    HDT_BA_DeleteProductAssociation deleteAssociationBatch = new HDT_BA_DeleteProductAssociation(executionType, optionalSkuId, recordList, '');
                    Id batchId = Database.executeBatch(deleteAssociationBatch);
                    respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                    respRunBatchObj.success = true;
                }
            }
            when 'filter' {
                //run batch for all Product2 using where condition

                String queryString = HDT_UTL_ProductAssociation.generateQueryString(filterString, 'AND', optionalSkuId, findMethod);
                System.debug(logginglevel.DEBUG, '>>> queryString: ' + queryString);

                HDT_BA_DeleteProductAssociation deleteAssociationBatch = new HDT_BA_DeleteProductAssociation(executionType, optionalSkuId, new List<String>(), queryString);
                Id batchId = Database.executeBatch(deleteAssociationBatch);
                respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                respRunBatchObj.success = true;
            }
        }

        return respRunBatchObj;
    }

    public static Map<String, Integer> createNumberProductOptionMap(AggregateResult[] results){
        Map<String, Integer> numberMap = new Map<String, Integer>();
        for (AggregateResult ar : results) {
            numberMap.put(String.valueOf(ar.get('SBQQ__ConfiguredSKU__c')), Integer.valueOf(ar.get('expr0')));
        }
        return numberMap;
    }

    public static void sendCustomNotification(HDT_WRP_ProductAssociation.HDT_WRP_Notification notificationWrp){
        //Userinfo.getUserId()
        try{
            Id typeId = HDT_QR_ProductAssociation.getCustomNotificationTypeId();
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(notificationWrp.title);
            notification.setBody(notificationWrp.body);
            notification.setSenderId(notificationWrp.userId);
            notification.setNotificationTypeId(typeId);
            notification.setTargetId(notificationWrp.targetId);
            notification.send(new Set<String> {notificationWrp.userId});
        } catch(Exception ex){
            System.debug(logginglevel.DEBUG, '>>> somethig goes wrong with comunication: ' + ex.getMessage() + ' [' + String.valueOf(ex.getLineNumber()) + ']');
        }

    }

    public static Map<Id, Id> generateSkuIdFeatureIdMap(List<SBQQ__ProductFeature__c> productFeatureList, Map<Id, Id> skuIdFeatureIdMap){
        for(SBQQ__ProductFeature__c productFeature : productFeatureList){
            skuIdFeatureIdMap.put(productFeature.SBQQ__ConfiguredSKU__c, productFeature.Id);
        }
        return skuIdFeatureIdMap;
    }

    public static List<String> getFamilyList(){
        List<String> sl = new List<String>();
        sl.add('Offerta commerciale');
        //sl.add('VAS Prodotto');
        //sl.add('VAS Servizio');
        return sl;
    }

}