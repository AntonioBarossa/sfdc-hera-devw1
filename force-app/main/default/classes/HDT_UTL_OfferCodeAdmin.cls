public with sharing class HDT_UTL_OfferCodeAdmin {
    public static void handleProduct(List <OfferCode32Admin__c> offerCodes) {
        Set<String> prodCodes=new Set<String>();
        Set<String> prodVersions=new Set<String>();
        for(OfferCode32Admin__c offCode : offerCodes){
            prodCodes.add(offCode.OfferProductCode__c);
            prodVersions.add(offCode.OfferProductVersion__c);
        }
        List <Product2> products=HDT_QR_Product.getProductsByCodeVersion(prodCodes, prodVersions);
        Map <String,Product2> productsMap=new Map <String,Product2>();
        for(Product2 prod : products){
            String key=prod.ProductCode+'_'+prod.Version__c;
            productsMap.put(key, prod);
        }
        for(OfferCode32Admin__c offCode : offerCodes){
            try{
                if(productsMap.containsKey(offCode.OfferProductCode__c+'_'+offCode.OfferProductVersion__c)){
                    offCode.Product2__c=productsMap.get(offCode.OfferProductCode__c+'_'+offCode.OfferProductVersion__c).Id;
                    offCode.Exported__c=false;
                }
                else{
                        throw new HDT_TRH_AmmCodiciOffertaException('Nessun Prodoto Corrispondente a questo codice trovato!');
                    }
            }
            catch (Exception ex){
                offCode.adderror('Nessun Prodoto Corrispondente a questo codice trovato!');
            }
        }  
    }

    private class HDT_TRH_AmmCodiciOffertaException extends Exception {}
}