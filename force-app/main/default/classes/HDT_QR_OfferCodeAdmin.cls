public with sharing class HDT_QR_OfferCodeAdmin {

    public static List<OfferCode32Admin__c> getOfferCodesByProdVersion(Set<String> prodCodes, Set<String> versions){
        List <OfferCode32Admin__c> offCodes = [
            SELECT id, OfferProductCode__c, OfferProductVersion__c
            FROM OfferCode32Admin__c WHERE OfferProductCode__c IN : prodCodes AND OfferProductVersion__c IN : versions
            WITH SECURITY_ENFORCED
        ];
        return offCodes;
    }

    public static List<OfferCode32Admin__c> getOfferCodesForOrder(String prodCode, String version, String salesCompany, String marketType, String comodity){
        List <OfferCode32Admin__c> offCodes = [
            SELECT id, OfferCode32__c, EffectiveDate__c, CodT0__c
            FROM OfferCode32Admin__c WHERE OfferProductCode__c =: prodCode AND OfferProductVersion__c =: version 
                                     AND Company__c=:salesCompany AND MarketType__c =: marketType AND Service__c =: comodity
            WITH SECURITY_ENFORCED ORDER BY EffectiveDate__c ASC NULLS FIRST
        ];
        return offCodes;
    }
}