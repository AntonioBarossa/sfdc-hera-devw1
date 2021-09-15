/**
* @author Keltin Mesonjesi
* @date 04/2021
* @description HDT_QR_PriceBook
* @history Keltin Mesonjesi – 04/2021 – Class Created 
*/

public inherited sharing class HDT_QR_PriceBook {
    
    public static List<Pricebook2> getRecordByName(String name) {
        return [
            SELECT  
            Id
            FROM Pricebook2
            WHERE Name = :name
            WITH SECURITY_ENFORCED
        ];
    }

}
