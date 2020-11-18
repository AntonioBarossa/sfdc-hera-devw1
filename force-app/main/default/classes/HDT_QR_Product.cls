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
        
        String fieldsToCheck = 'Name,ProductCode';
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Product2', fieldsToCheck, 'read');
        securityAccess.checkSecurityAccess();

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

}
