public with sharing class HDT_QR_BrandSalesCompany {


     /**
    * @author Elfrida Kora (elfrida.kora@dunegroup.it)
    * @description Get records by Id
    * @param String comune
    * @param String servizio
    * @param String societaVendita
    * @param String tipoMercato
    * @return List<BrandSalesCompany__c>
    */
     
    public List<BrandSalesCompany__c> getMatriceBrandById(String comune,String servizio,String societaVendita,String tipoMercato){
        return [
            SELECT 
            Id,
            CorporateBrand__c,
            CommonSupply__c,
            Service__c,
            SalesCompany__c,
			MarketType__c,
			ActiveFlgforACR__c,
			ActiveFlgforBrand__c
            FROM BrandSalesCompany__c 
            where CommonSupply__c = :comune
			AND Service__c = :servizio
			AND SalesCompany__c	= :societaVendita
			AND MarketType__c = :tipoMercato
			AND ActiveFlgforACR__c = true
			AND ActiveFlgforBrand__c = true
            WITH SECURITY_ENFORCED
        ];
    }
}
