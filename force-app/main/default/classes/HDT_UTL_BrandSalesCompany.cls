
/**
 * @author Elfrida Kora (elfrida.kora@dunegroup.it)
 * @date 14/07/2021
 * @description HDT_UTL_BrandSalesCompany.cls - Class that holds logic for Matrice Brand
 * @history Elfrida Kora  – 14/07/2021 – Created class
 */

public with sharing class HDT_UTL_BrandSalesCompany {
    
    public static HDT_QR_BrandSalesCompany bscQr = new HDT_QR_BrandSalesCompany();
    @AuraEnabled
    public static String getFieldsMatrice(String comune,String servizio,String societaVendita,String tipoMercato){

        List<BrandSalesCompany__c> res = bscQr.getMatriceBrandById(comune,servizio,societaVendita,tipoMercato);
        if(!res.isEmpty()){

        return res[0].CorporateBrand__c;
        }else{
            return '';
        }


    }
}
