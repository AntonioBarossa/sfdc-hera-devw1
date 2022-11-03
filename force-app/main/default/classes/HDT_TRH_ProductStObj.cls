@SuppressWarnings('PMD.AvoidDebugStatements')
public inherited sharing class HDT_TRH_ProductStObj extends HDT_TRH_TriggerHandler {

    public override void beforeInsert(){

        if(HDT_UTL_ProductStObjProcess.skipTrigger('HDT_ProductStObj')){
            return;
        }

        for(Product2 p : (Product2[])Trigger.New){
            p.Status__c = Label.HDT_InDevelopment;
            p.StartDate__c = null;
            p.EndDate__c = null;
        }
    }

    public override void beforeUpdate(){
        
        if(HDT_UTL_ProductStObjProcess.skipTrigger('HDT_ProductStObj')){
            return;
        }

        //Set<String> allUniqueProductCodeSet;
        Map<Id, Integer> productOptionMap;
        Map<Id, Integer> technicalOfferMap;
        //allUniqueProductCodeSet = checkProduct2Duplicate(allUniqueProductCodeSet);

        List<Product2> productForTrigger = new List<Product2>();
        Set<Id> productIds = new  Set<Id>();// = Trigger.NewMap.keySet();
        Set<Id> productIdsForProductOption = new  Set<Id>();
        Set<Id> productIdsForTechOff = new  Set<Id>();
        Set<String> familySet = new Set<String>();
        familySet.add('VAS Prodotto');
        familySet.add('VAS Servizio');
        familySet.add('Promozione');
        familySet.add('Offerta commerciale');

        for(Product2 p : (Product2[])Trigger.New){

            Product2 oldProd = (Product2)Trigger.oldMap.get(p.Id);

            if(oldProd.NoSellable__c != p.NoSellable__c){
                System.debug(LoggingLevel.DEBUG, '>>> this record skip trigger for NoSellable__c ');
                //p.addError('generic error');
                continue;
            }
            
            productForTrigger.add(p);

            if(familySet.contains(p.Family)){
                productIds.add(p.Id);

                //Product2 oldProd = (Product2)Trigger.oldMap.get(p.Id);

                // In Sviluppo --> Confermata
                if(oldProd.Status__c.equalsIgnoreCase(Label.HDT_InDevelopment) && p.Status__c.equalsIgnoreCase(Label.HDT_Confirmed)){

                    productIdsForProductOption.add(p.Id);

                    //Offerta commerciale
                    if(p.Family.equalsIgnoreCase(Label.HDT_ProductFamilyTrigger)){
                        productIdsForTechOff.add(p.Id);
                    }
                }
            }

        }

        System.debug(LoggingLevel.DEBUG, '>>> productForTrigger ' + productForTrigger.size());
        System.debug(LoggingLevel.DEBUG, '>>> productIds ' + productIds.size());
        System.debug(LoggingLevel.DEBUG, '>>> productIdsForProductOption ' + productIdsForProductOption.size());
        System.debug(LoggingLevel.DEBUG, '>>> productIdsForTechOff ' + productIdsForTechOff.size());

        if(productForTrigger.size()==0){
            return;
        }

        if(productIds.size()==0){
            // if not in familySet ship trigger
            return;
        }

        if(productIdsForProductOption.size()>0){
            productOptionMap = HDT_UTL_ProductStObjProcess.generateProductOptionMap(productOptionMap, productIdsForProductOption);
        }
        
        if(productIdsForTechOff.size() > 0){
            technicalOfferMap = HDT_UTL_ProductStObjProcess.generateTechnicalOfferMap(technicalOfferMap, productIdsForTechOff);
        }
        
        HDT_WRP_ProductStObjProcess.HDT_WRP_StatusResponse statusResponse;
        Integer technicalOfferNumber;
        Integer productOptioNumber;
        //for(Product2 p : (Product2[])Trigger.New){
        for(Product2 p : productForTrigger){

            //if(allUniqueProductCodeSet.size() > 0 && allUniqueProductCodeSet.contains(generateUniqueCode(p))){
            //    System.debug(LoggingLevel.DEBUG, '>>> ADD ERROR');
            //    p.addError(generateErrorMessage((p)));
            //}

            Product2 oldProduct = (Product2)Trigger.OldMap.get(p.Id);
            System.debug(LoggingLevel.DEBUG, '>>> oldStatus: ' + oldProduct.Status__c + ' - NewStatus: ' + p.Status__c);

            if(technicalOfferMap == null|| !technicalOfferMap.containsKey(p.Id)){
                technicalOfferNumber = 0;
            } else {
                technicalOfferNumber = technicalOfferMap.get(p.Id);
            }

            if(productOptionMap == null || !productOptionMap.containsKey(p.Id)){
                productOptioNumber = 0;
            } else {
                productOptioNumber = productOptionMap.get(p.Id);
            }

            statusResponse = HDT_UTL_ProductStObjProcess.changeStatusHandler(statusResponse, p.Id, oldProduct, p, productOptioNumber, technicalOfferNumber);
            System.debug(LoggingLevel.DEBUG, '>>> statusResponse: ' + statusResponse.success + ' - ' + statusResponse.message);

            if(!statusResponse.success){
                p.addError(statusResponse.message);
            }

        }

    }

    /*@TestVisible
    private static Set<String> checkProduct2Duplicate(Set<String> allUniqueProductCodeSet){

        Boolean isUpdate = Trigger.isUpdate;
        List<Product2> productsList = new List<Product2>();
        List<String> productCodeList = new List<String>();
        List<String> versionList = new List<String>();
        List<String> descriptionSapList = new List<String>();
        Set<Id> idSet = new Set<Id>();
        Set<String> uniqueProductCodeSet = new Set<String>();
        allUniqueProductCodeSet = new Set<String>();
        

        for(Product2 p : (Product2[])Trigger.New){
            productCodeList.add(p.ProductCode);
            versionList.add(p.Version__c);
            descriptionSapList.add(p.DescriptionSAP__c);

            if(isUpdate)
                idSet.add(p.Id);
        }

        productsList = [
            SELECT Id, ProductCode, Version__c, DescriptionSAP__c
            FROM Product2
            WHERE ProductCode IN :productCodeList AND Version__c IN :versionList AND DescriptionSAP__c IN :descriptionSapList
            WITH SECURITY_ENFORCED
        ];

        System.debug(LoggingLevel.DEBUG, '>>> productsListSize ' + productsList.size());

        if(productsList.size() > 0){
            for(Product2 prod : productsList){
                if(isUpdate && idSet.contains(prod.Id)){
                    System.debug(LoggingLevel.DEBUG, '>>> SAME RECORD IN UPDATE...');
                } else {
                    allUniqueProductCodeSet.add(generateUniqueCode(prod));
                }
            }
        }

        return allUniqueProductCodeSet;
    }*/

    //private static String generateUniqueCode(Product2 product){
    //    return product.ProductCode + '_' + product.Version__c + '_' + product.DescriptionSAP__c;
    //}

    //private static String generateErrorMessage(Product2 product){
    //    String s = 'ATTENZIONE! Valori inseriti già esistenti: ';
    //    s += '[ProductCode=' + product.ProductCode + '], [Version=' + product.Version__c + '], [DescriptionSAP=' + product.DescriptionSAP__c + ']';
    //    return s;
    //}

}