public with sharing class HDT_UTL_RuleAssociation {

    public static String generateQueryString(String filterString, String operator, String ruleId, String findMethod){
        
        String op = ' ' + operator + ' ';
        String queryString = '';
        List<String> familyList = HDT_UTL_ProductAssociation.getFamilyList();

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

        //if(!String.isEmpty(filterProduct.Family)){
        //    whereConditionList.add('Family = \'' + filterProduct.Family + '\'');
        //}

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

        queryString +=  ' (SELECT SBQQ__Product__c FROM SBQQ__ConfigurationRule__c WHERE SBQQ__ProductRule__c = \'' + ruleId + '\') ';
        queryString += 'AND Family IN (\'' + String.join(familyList, '\',\'') + '\')';
        
        //if(!String.isEmpty(filterProduct.Family)){
        //    queryString += ',\'' + filterProduct.Family + '\'';
        //}

        //queryString += ;

        return queryString;
    }

    public static HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj createProductRuleAssociation(HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj, String confRuleObj, List<String> recordList, String executionType, String filterString, String findMethod){
        
        System.debug('>>> createProductOptionAssociation');

        respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();

        SBQQ__ConfigurationRule__c configurationRuleToClone = (SBQQ__ConfigurationRule__c)JSON.deserialize(confRuleObj, SBQQ__ConfigurationRule__c.class);

        switch on executionType {
            when 'select' {
                //run batch for selected record -> recordList > 0

                if(recordList.size() < 10){
                    // NO BATCH NEEDED, YOU CAN UPDATE HERE
                    HDT_WRP_ProductAssociation.HDT_WRP_InsertResult insertReult;// = HDT_SRV_ProductAssociation.associateProductRule(configurationRuleToClone, recordList);

                    if(insertReult.success){
                        respRunBatchObj.success = true;
                        respRunBatchObj.message = Label.ProdOptAssociationSuccessCreate;
                    } else {
                        respRunBatchObj.success = false;
                        respRunBatchObj.message = insertReult.message;
                    }
                    
                } else {
                    //HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(executionType, configurationRuleToClone, recordList, '');
                    //Id batchId = Database.executeBatch(createAssociationBatch);
                    respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                    respRunBatchObj.success = true;
                }
            }	
            when 'filter' {
                //run batch for all Product2 using where condition

                //String queryString = HDT_UTL_ProductAssociation.generateQueryString(filterString, 'AND', configurationRuleToClone.SBQQ__OptionalSKU__c, findMethod);
                //System.debug('>>> queryString: ' + queryString);
                //
                //HDT_BA_ProductAssociation createAssociationBatch = new HDT_BA_ProductAssociation(executionType, productOptionToClone, new List<String>(), queryString);
                //Id batchId = Database.executeBatch(createAssociationBatch);
                respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                respRunBatchObj.success = true;
            }
        }

        return respRunBatchObj;
    }

    public static HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj deleteProductRuleAssociation(HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj respRunBatchObj, String ruleId, List<String> recordList, String executionType, String filterString, String findMethod){
        
        System.debug('>>> deleteProductOptionAssociation');
        
        respRunBatchObj = new HDT_WRP_ProductAssociation.HDT_WRP_RespRunBatchObj();

        switch on executionType {
            when 'select' {
                //run batch for selected record -> recordList > 0

                if(recordList.size() < 10){
                    // NO BATCH NEEDED, YOU CAN DELETE HERE
                    List<SBQQ__ConfigurationRule__c> productRuleToDelete;
                    //productRuleToDelete = HDT_QR_ProductAssociation.getProductOptionByOptionalSkuAndConfiguredSku(productRuleToDelete, ruleId, recordList);

                    SObjectType objtype = Schema.getGlobalDescribe().get('SBQQ__ConfigurationRule__c');
                    Schema.DescribeSObjectResult objRes = objtype.getDescribe();
             
                    if(objRes.isDeletable ()){
                        try{
                            List<HDT_WRP_ProductAssociation.HDT_WRP_LineError> errorData;
                            //errorData = HDT_SRV_ProductAssociation.deleteProductOption(productRuleToDelete, errorData);

                            if(errorData.size() > 0){
                                respRunBatchObj.success = false;
                                respRunBatchObj.message = 'Si sono verificati [' + String.valueOf(errorData.size()) + '] errori.';
                            } else {
                                respRunBatchObj.success = true;
                                respRunBatchObj.message = Label.ProdOptAssociationSuccessDelete;
                            }

                        } catch(Exception ex){
                            respRunBatchObj.success = false;
                            respRunBatchObj.message = ex.getMessage() + ' at line [' + String.valueOf(ex.getLineNumber()) + ']';
                        }
                        
                    }
                    
                } else {
                    //HDT_BA_DeleteProductAssociation deleteAssociationBatch = new HDT_BA_DeleteProductAssociation(executionType, optionalSkuId, recordList, '');
                    //Id batchId = Database.executeBatch(deleteAssociationBatch);
                    respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                    respRunBatchObj.success = true;
                }
            }
            when 'filter' {
                //run batch for all Product2 using where condition

                //String queryString = HDT_UTL_ProductAssociation.generateQueryString(filterString, 'AND', optionalSkuId, findMethod);
                //System.debug('>>> queryString: ' + queryString);

                //HDT_BA_DeleteProductAssociation deleteAssociationBatch = new HDT_BA_DeleteProductAssociation(executionType, optionalSkuId, new List<String>(), queryString);
                //Id batchId = Database.executeBatch(deleteAssociationBatch);
                respRunBatchObj.message = Label.ProdOptAssociationRunBatch;
                respRunBatchObj.success = true;
            }
        }

        return respRunBatchObj;
    }

}