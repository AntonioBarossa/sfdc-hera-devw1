/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 17/11/2020
* @description HDT_QR_Product – Contains queries for Product2
* @history Keltin Mesonjesi – 17/11/2020 – Created class
*/

public inherited sharing class HDT_QR_Product {

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Get single record by Product2.ProductCode
    * @param String productCode – Product2.ProductCode
    * @return Product2
    */
    public Product2 getRecordByProductCode(String productCode){

        List<Product2> records = [
            SELECT
            Name,
            ProductCode
            FROM Product2
            WHERE ProductCode =: productCode
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return records[0];

    }

    public static List<Product2> getAllProducts(String IdGruppoEleggibilitCampagne) {
        return [
            SELECT 
            Id,
            Name,
            CampaignEleggibilityGroup__c
            FROM Product2
            WHERE Status__c != 'Scaduta'
            AND (CampaignEleggibilityGroup__c = :IdGruppoEleggibilitCampagne OR CampaignEleggibilityGroup__c = null)
            WITH SECURITY_ENFORCED
        ];
    }

    public static List<Product2> getProductsByCodeVersion(Set<String> prodCodes, Set<String> prodVersions) {
        return [
            SELECT 
            Id,
            ProductCode,
            Version__c
            FROM Product2
            WHERE Family='Offerta commerciale'
            AND ProductCode IN : prodCodes AND Version__c IN : prodVersions
            WITH SECURITY_ENFORCED
        ];
    }

}