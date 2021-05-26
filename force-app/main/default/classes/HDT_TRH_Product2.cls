public inherited sharing class HDT_TRH_Product2 extends HDT_TRH_TriggerHandler {

    public override void beforeInsert(){
        //for(Product2 p : (Product2[])Trigger.New){
        //    p.Status__c = 'In Sviluppo';
        //}
    }

    public override void beforeUpdate(){
        
        Set<String> allUniqueProductCodeSet;
        allUniqueProductCodeSet = checkProduct2Duplicate(allUniqueProductCodeSet);

        HDT_WRP_Product2Process.HDT_WRP_StatusResponse statusResponse;
        for(Product2 p : (Product2[])Trigger.New){

            if(allUniqueProductCodeSet.size() > 0 && allUniqueProductCodeSet.contains(generateUniqueCode(p))){
                System.debug('>>> ADD ERROR');
                //p.addError(generateErrorMessage((p)));
            }

            Product2 oldProduct = (Product2)Trigger.OldMap.get(p.Id);
            System.debug('>>> oldStatus: ' + oldProduct.Status__c + ' - NewStatus: ' + p.Status__c);
            statusResponse = HDT_UTL_Product2Process.changeStatusHandler(statusResponse, p.Id, oldProduct, p);
            System.debug('>>> statusResponse: ' + statusResponse.success + ' - ' + statusResponse.message);

            if(!statusResponse.success){
                p.addError(statusResponse.message);
            }

        }

    }

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

        System.debug('>>> productsListSize ' + productsList.size());

        if(productsList.size() > 0){
            for(Product2 prod : productsList){
                if(isUpdate && idSet.contains(prod.Id)){
                    System.debug('>>> SAME RECORD IN UPDATE...');
                } else {
                    allUniqueProductCodeSet.add(generateUniqueCode(prod));
                }
            }
        }

        return allUniqueProductCodeSet;
    }

    private static String generateUniqueCode(Product2 product){
        return product.ProductCode + '_' + product.Version__c + '_' + product.DescriptionSAP__c;
    }

    private static String generateErrorMessage(Product2 product){
        String s = 'ATTENZIONE! Valori inseriti già esistenti: ';
        s += '[ProductCode=' + product.ProductCode + '], [Version=' + product.Version__c + '], [DescriptionSAP=' + product.DescriptionSAP__c + ']';
        return s;
    }

}